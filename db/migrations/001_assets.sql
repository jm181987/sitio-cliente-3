CREATE TABLE IF NOT EXISTS assets (
  id BIGSERIAL PRIMARY KEY,
  bucket TEXT NOT NULL,
  object_key TEXT NOT NULL UNIQUE,
  original_name TEXT,
  mime_type TEXT,
  size_bytes BIGINT,
  public_url TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS assets_bucket_idx ON assets(bucket);
CREATE INDEX IF NOT EXISTS assets_created_at_idx ON assets(created_at DESC);
