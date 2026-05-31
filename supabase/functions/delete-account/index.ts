/// <reference lib="deno.ns" />

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const USER_BUCKETS = ["receipts", "cars", "profiles"];

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Authorization header is required" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // 1) JWT 검증 (anon 클라이언트로 사용자 식별)
    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user }, error: authError } = await userClient.auth.getUser();
    if (authError || !user) {
      return jsonResponse({ error: "Invalid or expired token" }, 401);
    }

    const userId = user.id;
    console.log(`[delete-account] start userId=${userId}`);

    // 2) service_role 클라이언트로 스토리지/계정 삭제
    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    // 2-1) 사용자 폴더의 모든 객체 삭제
    for (const bucket of USER_BUCKETS) {
      try {
        const removed = await purgeUserFolder(adminClient, bucket, userId);
        console.log(`[delete-account] bucket=${bucket} removed=${removed}`);
      } catch (e) {
        console.error(`[delete-account] bucket=${bucket} error`, e);
        // 스토리지 삭제 실패는 계정 삭제를 막지 않는다. (auth.users 삭제가 핵심)
      }
    }

    // 2-2) auth.users 삭제 → public.users → cars → maintenance_records … 캐스케이드
    const { error: deleteError } = await adminClient.auth.admin.deleteUser(userId);
    if (deleteError) {
      console.error("[delete-account] auth.admin.deleteUser failed", deleteError);
      return jsonResponse({ error: deleteError.message }, 500);
    }

    console.log(`[delete-account] success userId=${userId}`);
    return jsonResponse({ success: true });
  } catch (e) {
    console.error("[delete-account] unexpected", e);
    return jsonResponse(
      { error: e instanceof Error ? e.message : "Unknown error" },
      500,
    );
  }
});

async function purgeUserFolder(
  adminClient: ReturnType<typeof createClient>,
  bucket: string,
  userId: string,
): Promise<number> {
  let totalRemoved = 0;
  // Supabase Storage list는 한 번에 폴더 내 객체만 반환하므로 재귀적으로 수집
  const queue: string[] = [userId];
  const allPaths: string[] = [];

  while (queue.length > 0) {
    const prefix = queue.shift()!;
    const { data, error } = await adminClient.storage.from(bucket).list(prefix, {
      limit: 1000,
    });
    if (error) throw error;
    if (!data) continue;

    for (const item of data) {
      const path = `${prefix}/${item.name}`;
      // 객체에는 metadata가 있고, 폴더에는 없다.
      if (item.id === null || item.metadata === null) {
        queue.push(path);
      } else {
        allPaths.push(path);
      }
    }
  }

  if (allPaths.length === 0) return 0;

  // 1000개씩 배치 삭제
  for (let i = 0; i < allPaths.length; i += 1000) {
    const batch = allPaths.slice(i, i + 1000);
    const { error } = await adminClient.storage.from(bucket).remove(batch);
    if (error) throw error;
    totalRemoved += batch.length;
  }
  return totalRemoved;
}

function jsonResponse(body: unknown, status: number = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
