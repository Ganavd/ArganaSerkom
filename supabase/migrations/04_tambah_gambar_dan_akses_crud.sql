-- =====================================================================
-- FILE 4 — jalankan SETELAH 01, 02, 03.
-- Tujuan: (a) nambah kolom buat nyimpen link gambar produk,
--         (b) buka akses CRUD (create/update/delete) dari browser
--             LANGSUNG ke Supabase, tanpa lewat Express lagi,
--         (c) siapin tempat penyimpanan file gambar PNG/JPG (Storage bucket).
--
-- !! PENTING — INI KEPUTUSAN SADAR UNTUK LATIHAN, BUKAN BUAT PRODUKSI !!
-- Karena belum ada sistem login, policy di bawah ini `USING (true)` /
-- `WITH CHECK (true)` artinya SEMUA ORANG yang tahu Project URL + anon
-- key kamu (yang memang nongol di kode browser) BISA tambah/ubah/hapus
-- data siapa saja, tanpa harus login. Ini sengaja dipilih karena tujuan
-- sekarang cuma latihan CRUD + relasi tabel untuk ujian. Kalau nanti web
-- ini beneran dipakai jualan, policy ini WAJIB diganti supaya cuma admin
-- yang bisa INSERT/UPDATE/DELETE (pakai Supabase Auth + cek auth.uid()).
-- =====================================================================

-- ---------------------------------------------------------------------
-- (a) Kolom baru untuk menyimpan URL gambar produk (bukan file-nya
--     sendiri — file gambar disimpan di Supabase Storage, tabel cuma
--     nyimpen ALAMAT/LINK-nya, mirip <img src="...">).
-- ---------------------------------------------------------------------
ALTER TABLE produk ADD COLUMN IF NOT EXISTS gambar_url TEXT;

-- ---------------------------------------------------------------------
-- (b) Row Level Security (RLS) + Policy.
--
-- Cara mikir RLS: begitu ENABLE ROW LEVEL SECURITY dinyalakan, TABEL
-- TERKUNCI TOTAL secara default — tidak ada satupun query yang boleh
-- lewat, sampai kita buat POLICY yang mengizinkan aksi tertentu.
-- Satu POLICY = satu aturan untuk satu jenis aksi (SELECT / INSERT /
-- UPDATE / DELETE).
-- ---------------------------------------------------------------------
ALTER TABLE produk   ENABLE ROW LEVEL SECURITY;
ALTER TABLE kategori ENABLE ROW LEVEL SECURITY;

-- Baca (SELECT): boleh siapa saja — wajar, produk toko memang publik.
DROP POLICY IF EXISTS "produk_select_publik" ON produk;
CREATE POLICY "produk_select_publik"
  ON produk FOR SELECT USING (true);
DROP POLICY IF EXISTS "kategori_select_publik" ON kategori;
CREATE POLICY "kategori_select_publik"
  ON kategori FOR SELECT USING (true);

-- Tambah (INSERT): USING tidak dipakai untuk INSERT, yang dipakai
-- WITH CHECK — aturan yang dicek pada BARIS BARU yang mau dimasukkan.
-- `true` = baris apapun boleh masuk, tanpa syarat.
DROP POLICY IF EXISTS "produk_insert_terbuka" ON produk;
CREATE POLICY "produk_insert_terbuka"
  ON produk FOR INSERT WITH CHECK (true);

-- Ubah (UPDATE): USING mengecek baris yang MAU diubah,
-- WITH CHECK mengecek hasil SETELAH diubah. Sama-sama `true` di sini.
DROP POLICY IF EXISTS "produk_update_terbuka" ON produk;
CREATE POLICY "produk_update_terbuka"
  ON produk FOR UPDATE USING (true) WITH CHECK (true);

-- Hapus (DELETE): USING mengecek baris mana saja yang boleh dihapus.
DROP POLICY IF EXISTS "produk_delete_terbuka" ON produk;
CREATE POLICY "produk_delete_terbuka"
  ON produk FOR DELETE USING (true);

-- ---------------------------------------------------------------------
-- (c) Storage bucket untuk file gambar (PNG).
-- Supabase Storage itu terpisah dari tabel biasa — dia nyimpen FILE
-- (gambar, pdf, dll), bukan baris data. Tapi tetap "hidup" di dalam
-- project Supabase yang sama, dan tetap diatur pakai RLS-style policy,
-- cuma tabelnya bernama storage.objects (bawaan Supabase).
-- ---------------------------------------------------------------------

-- Daftarkan bucket baru bernama 'produk-images'.
-- public = true -> file di dalamnya bisa diakses lewat URL publik
-- langsung (cocok buat gambar produk yang memang harus tampil di web),
-- tanpa perlu key khusus untuk MELIHAT gambarnya.
INSERT INTO storage.buckets (id, name, public)
VALUES ('produk-images', 'produk-images', true)
ON CONFLICT (id) DO NOTHING;

-- Siapa saja boleh MELIHAT (SELECT) file di bucket ini -> gambar bisa
-- tampil di halaman toko tanpa syarat.
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
-- (dipakai kalau nanti mau fitur "ganti gambar" tanpa upload nama file baru).
DROP POLICY IF EXISTS "gambar_update_terbuka" ON storage.objects;
CREATE POLICY "gambar_update_terbuka"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'produk-images');

-- Siapa saja boleh hapus (DELETE) file di bucket ini.
DROP POLICY IF EXISTS "gambar_delete_terbuka" ON storage.objects;
CREATE POLICY "gambar_delete_terbuka"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'produk-images');
