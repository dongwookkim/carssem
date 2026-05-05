-- Enable pg_trgm extension for trigram search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Regions (법정동) table
CREATE TABLE IF NOT EXISTS regions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  sido TEXT NOT NULL,
  sigungu TEXT NOT NULL,
  eupmyeondong TEXT NOT NULL,
  full_name TEXT NOT NULL
);

-- Trigram index for ilike search performance
CREATE INDEX IF NOT EXISTS idx_regions_full_name_trgm
  ON regions USING gin (full_name gin_trgm_ops);

-- RLS
ALTER TABLE regions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read regions"
  ON regions FOR SELECT
  TO authenticated
  USING (true);
