ALTER TABLE produk ADD COLUMN IF NOT EXISTS gambar_url TEXT;

ALTER TABLE produk   ENABLE ROW LEVEL SECURITY;
ALTER TABLE kategori ENABLE ROW LEVEL SECURITY;

-- Baca (SELECT)
DROP POLICY IF EXISTS "produk_select_publik" ON produk;
CREATE POLICY "produk_select_publik"
  ON produk FOR SELECT USING (true);
DROP POLICY IF EXISTS "kategori_select_publik" ON kategori;
CREATE POLICY "kategori_select_publik"
  ON kategori FOR SELECT USING (true);

-- Tambah (INSERT)
DROP POLICY IF EXISTS "produk_insert_terbuka" ON produk;
CREATE POLICY "produk_insert_terbuka"
  ON produk FOR INSERT WITH CHECK (true);

-- Ubah (UPDATE)
DROP POLICY IF EXISTS "produk_update_terbuka" ON produk;
CREATE POLICY "produk_update_terbuka"
  ON produk FOR UPDATE USING (true) WITH CHECK (true);

-- Hapus (DELETE)
DROP POLICY IF EXISTS "produk_delete_terbuka" ON produk;
CREATE POLICY "produk_delete_terbuka"
  ON produk FOR DELETE USING (true);


-- Daftarkan bucket baru bernama 'produk-images'.
INSERT INTO storage.buckets (id, name, public)
VALUES ('produk-images', 'produk-images', true)
ON CONFLICT (id) DO NOTHING;

-- Siapa saja boleh MELIHAT (SELECT) file di bucket ini 
DROP POLICY IF EXISTS "gambar_select_publik" ON storage.objects;
CREATE POLICY "gambar_select_publik"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'produk-images');

-- Siapa saja boleh UPLOAD (INSERT) file baru ke bucket ini.
DROP POLICY IF EXISTS "gambar_insert_terbuka" ON storage.objects;
CREATE POLICY "gambar_insert_terbuka"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'produk-images');

-- Siapa saja boleh ganti (UPDATE) file yang sudah ada di bucket ini
DROP POLICY IF EXISTS "gambar_update_terbuka" ON storage.objects;
CREATE POLICY "gambar_update_terbuka"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'produk-images');

-- Siapa saja boleh hapus (DELETE) file di bucket ini.
DROP POLICY IF EXISTS "gambar_delete_terbuka" ON storage.objects;
CREATE POLICY "gambar_delete_terbuka"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'produk-images');
