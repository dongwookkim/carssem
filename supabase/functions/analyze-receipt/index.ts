/// <reference lib="deno.ns" />

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { encode as base64Encode } from "https://deno.land/std@0.168.0/encoding/base64.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import type { AnalysisResponse, AnalysisResult, DriverSummary } from "./types.ts";

const ANALYZE_RECEIPT_PROMPT = Deno.readTextFileSync(
  new URL("./prompt.md", import.meta.url),
);

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 인증 확인
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Authorization header is required" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Supabase 클라이언트로 사용자 검증
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: authError } = await supabase.auth.getUser();

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid or expired token" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    console.log(`Authenticated user: ${user.id}`);

    const { imageUrl } = await req.json();

    if (!imageUrl) {
      return new Response(
        JSON.stringify({ error: "imageUrl is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const openaiApiKey = Deno.env.get("OPENAI_API_KEY");
    if (!openaiApiKey) {
      return new Response(
        JSON.stringify({ error: "OpenAI API key not configured" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Download image and convert to base64
    const imageResponse = await fetch(imageUrl);
    if (!imageResponse.ok) {
      return new Response(
        JSON.stringify({ error: "Failed to download image from storage" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }
    const imageBytes = new Uint8Array(await imageResponse.arrayBuffer());
    const base64Image = base64Encode(imageBytes);
    const contentType = imageResponse.headers.get("content-type") || "image/jpeg";
    const dataUrl = `data:${contentType};base64,${base64Image}`;

    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${openaiApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-5.4-mini",
        messages: [
          {
            role: "user",
            content: [
              { type: "text", text: ANALYZE_RECEIPT_PROMPT },
              { type: "image_url", image_url: { url: dataUrl } },
            ],
          },
        ],
        max_completion_tokens: 4000,
        response_format: { type: "json_object" },
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("OpenAI API error:", errorText);
      return new Response(
        JSON.stringify({ error: "Failed to analyze image", details: errorText }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const data = await response.json();
    const content = data.choices[0]?.message?.content;

    if (!content) {
      return new Response(
        JSON.stringify({ error: "No response from AI" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Extract JSON from response (handle markdown code blocks)
    let jsonStr = content;
    const jsonMatch = content.match(/```(?:json)?\s*([\s\S]*?)```/);
    if (jsonMatch) {
      jsonStr = jsonMatch[1].trim();
    }

    // Parse and validate the result
    let result: Record<string, unknown>;
    try {
      result = JSON.parse(jsonStr);
    } catch (parseError) {
      console.error("JSON parse error:", parseError, "Content:", content);
      return new Response(
        JSON.stringify({
          error: "Failed to parse AI response",
          raw_content: content
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Handle invalid document
    if (result.is_valid === false) {
      const invalidResponse: AnalysisResponse = { is_valid: false };
      return new Response(
        JSON.stringify(invalidResponse),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Sanitize driver_summary
    const rawSummary = (result.driver_summary ?? {}) as Record<string, unknown>;
    const driverSummary: DriverSummary = {
      one_line: typeof rawSummary.one_line === "string" ? rawSummary.one_line : "",
      reason: typeof rawSummary.reason === "string" ? rawSummary.reason : "",
      work_done: typeof rawSummary.work_done === "string" ? rawSummary.work_done : "",
      impact: typeof rawSummary.impact === "string" ? rawSummary.impact : "",
      cost_explanation: typeof rawSummary.cost_explanation === "string" ? rawSummary.cost_explanation : "",
    };

    // Ensure required fields have default values
    const sanitizedResult: AnalysisResult = {
      is_valid: true,
      language: typeof result.language === "string" ? result.language : "ko",
      date: (result.date as string) || null,
      garage_name: (result.garage_name as string) || null,
      garage_address: (result.garage_address as string) || null,
      mechanic: (result.mechanic as string) || null,
      mileage: typeof result.mileage === "number" ? result.mileage : 0,
      items: Array.isArray(result.items)
        ? (result.items as Record<string, unknown>[]).map((item) => ({
            system: typeof item.system === "string" ? item.system : "",
            category: typeof item.category === "string" ? item.category : "기타",
            name: typeof item.name === "string" ? item.name : "항목",
            description: typeof item.description === "string" ? item.description : "",
            role: typeof item.role === "string" ? item.role : "",
            reason: typeof item.reason === "string" ? item.reason : "",
            quantity: typeof item.quantity === "number" ? item.quantity : 1,
            unit_price: typeof item.unit_price === "number" ? item.unit_price : 0,
            total_price: typeof item.total_price === "number" ? item.total_price : 0,
          }))
        : [],
      total_cost: typeof result.total_cost === "number" ? result.total_cost : 0,
      currency: typeof result.currency === "string" ? result.currency : "KRW",
      car_brand: (result.car_brand as string) || null,
      car_model: (result.car_model as string) || null,
      car_year: typeof result.car_year === "number" ? result.car_year : null,
      license_plate: typeof result.license_plate === "string"
        ? (result.license_plate.replace(/\s+/g, "") || null)
        : null,
      driver_summary: driverSummary,
    };

    return new Response(JSON.stringify(sanitizedResult), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error", details: String(error) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
