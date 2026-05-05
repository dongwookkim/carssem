-- =============================================
-- Device ID 기반 인증으로 전환
-- =============================================

-- users 테이블에 device_id 컬럼 추가
ALTER TABLE public.users ADD COLUMN device_id TEXT UNIQUE;

-- email 컬럼을 nullable로 변경 (Device 기반 사용자는 이메일 없음)
ALTER TABLE public.users ALTER COLUMN email DROP NOT NULL;

-- device_id 인덱스
CREATE INDEX idx_users_device_id ON public.users(device_id);

-- handle_new_user 트리거 업데이트 (anonymous/device 사용자 지원)
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, name, device_id)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', ''),
        NEW.raw_user_meta_data->>'device_id'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
