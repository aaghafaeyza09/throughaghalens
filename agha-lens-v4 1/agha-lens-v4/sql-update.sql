-- ============================================================
-- THROUGH AGHA LENS — SQL Update Script (v4)
-- Jalankan di: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- ── 1. Tambahkan kolom yang mungkin belum ada di tabel photos ──
ALTER TABLE photos ADD COLUMN IF NOT EXISTS visible BOOLEAN DEFAULT true;
ALTER TABLE photos ADD COLUMN IF NOT EXISTS location TEXT DEFAULT '';
ALTER TABLE photos ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Update image_url dari public_url jika kolom image_url masih kosong
UPDATE photos SET image_url = public_url WHERE image_url IS NULL;

-- ── 2. Buat tabel settings untuk menyimpan konfigurasi situs ──
CREATE TABLE IF NOT EXISTS settings (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── 3. Aktifkan Row Level Security pada tabel settings ──
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- ── 4. Policy: Publik bisa MEMBACA semua settings ──
CREATE POLICY "Public can view settings"
  ON settings FOR SELECT
  USING (true);

-- ── 5. Policy: Hanya admin (authenticated) yang bisa INSERT settings ──
CREATE POLICY "Admin can insert settings"
  ON settings FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- ── 6. Policy: Hanya admin yang bisa UPDATE settings ──
CREATE POLICY "Admin can update settings"
  ON settings FOR UPDATE
  USING (auth.role() = 'authenticated');

-- ── 7. Policy: Hanya admin yang bisa DELETE settings ──
CREATE POLICY "Admin can delete settings"
  ON settings FOR DELETE
  USING (auth.role() = 'authenticated');

-- ── 8. Buat Storage Bucket untuk foto profil ──
INSERT INTO storage.buckets (id, name, public)
VALUES ('profiles', 'profiles', true)
ON CONFLICT (id) DO NOTHING;

-- ── 9. Policy storage: Publik bisa melihat file di bucket profiles ──
CREATE POLICY "Public can view profile files"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profiles');

-- ── 10. Policy storage: Admin bisa upload ke bucket profiles ──
CREATE POLICY "Admin can upload profile files"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'profiles' AND auth.role() = 'authenticated');

-- ── 11. Policy storage: Admin bisa hapus dari bucket profiles ──
CREATE POLICY "Admin can delete profile files"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'profiles' AND auth.role() = 'authenticated');

-- ── 12. Seed nilai default (placeholder) untuk profile_photo_url ──
INSERT INTO settings (key, value)
VALUES ('profile_photo_url', '')
ON CONFLICT (key) DO NOTHING;

-- ── Selesai ──
SELECT 'SQL Update v4 berhasil dijalankan! ✓' AS status;
