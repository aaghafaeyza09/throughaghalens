-- ============================================
-- THROUGH AGHA LENS — Supabase Setup Script
-- Run this in: Supabase > SQL Editor > New Query
-- ============================================

-- 1. Photos table
CREATE TABLE IF NOT EXISTS photos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL DEFAULT 'Untitled',
  description TEXT DEFAULT '',
  category TEXT DEFAULT 'Miscellaneous',
  storage_path TEXT NOT NULL,
  public_url TEXT NOT NULL,
  taken_at DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable Row Level Security
ALTER TABLE photos ENABLE ROW LEVEL SECURITY;

-- 3. Public can read all photos
CREATE POLICY "Public can view photos"
  ON photos FOR SELECT
  USING (true);

-- 4. Only authenticated admin can insert/update/delete
CREATE POLICY "Admin can insert photos"
  ON photos FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admin can update photos"
  ON photos FOR UPDATE
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admin can delete photos"
  ON photos FOR DELETE
  USING (auth.role() = 'authenticated');

-- 5. Create storage bucket for photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('photos', 'photos', true)
ON CONFLICT (id) DO NOTHING;

-- 6. Public can view photos in storage
CREATE POLICY "Public can view photo files"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'photos');

-- 7. Only admin can upload/delete from storage
CREATE POLICY "Admin can upload photos"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'photos' AND auth.role() = 'authenticated');

CREATE POLICY "Admin can delete photo files"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'photos' AND auth.role() = 'authenticated');

-- Done!
SELECT 'Setup complete! ✓' AS status;
