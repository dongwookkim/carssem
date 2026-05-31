-- 강제 업데이트 기능: 플랫폼별 최소 지원 앱 버전 관리
CREATE TABLE IF NOT EXISTS app_versions (
  platform TEXT PRIMARY KEY CHECK (platform IN ('ios', 'android')),
  min_supported_version TEXT NOT NULL,
  update_message TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE app_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "app_versions_read" ON app_versions
  FOR SELECT
  TO anon, authenticated
  USING (true);

INSERT INTO app_versions (platform, min_supported_version) VALUES
  ('ios', '1.0.0'),
  ('android', '1.0.0')
ON CONFLICT (platform) DO NOTHING;
