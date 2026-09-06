-- =====================================================================
-- FILE 3 dari 3 — jalankan PALING TERAKHIR, setelah kedua tabel dibuat.
-- Isi: data dummy (contoh) untuk toko rajut.
-- =====================================================================

-- ---------------------------------------------------------------------
-- LANGKAH A: isi tabel kategori dulu (parent), baru produk (child).
-- ---------------------------------------------------------------------
INSERT INTO kategori (nama, slug) VALUES
  ('baju', 'baju'),
  ('sweater', 'sweater'),
  ('tas', 'tas'),
  ('mainan', 'mainan')
-- ON CONFLICT DO NOTHING = kalau baris ini dijalankan ulang dan nama
-- kategorinya sudah ada (ingat, kolom `nama` kita buat UNIQUE), Postgres
-- tidak error, cukup lewati baris yang sudah ada. Ini bikin file seed
-- aman dijalankan berkali-kali (disebut "idempotent").
ON CONFLICT (nama) DO NOTHING;

-- ---------------------------------------------------------------------
-- LANGKAH B: isi tabel produk.
-- ---------------------------------------------------------------------
-- Perhatikan: kita TIDAK menulis angka id kategori secara manual
-- (misalnya "kategori_id = 1"). Kenapa? Karena urutan id di Supabase
-- bisa berubah tergantung riwayat insert sebelumnya, jadi menebak
-- "baju pasti id 1" itu rapuh (fragile).
--
-- Sebagai gantinya, kita pakai SUBQUERY:
--   (SELECT id FROM kategori WHERE nama = 'baju')
-- yaitu query kecil DI DALAM query lain. Postgres akan menjalankan
-- bagian dalam kurung dulu (cari id kategori 'baju'), baru hasil
-- angkanya dipakai untuk mengisi kolom kategori_id. Ini pola yang
-- sangat umum dipakai untuk kerja dengan FOREIGN KEY.
INSERT INTO produk (kategori_id, nama, harga, deskripsi, stok) VALUES
  ((SELECT id FROM kategori WHERE nama = 'baju'),
    'Baju Rajut Wol Krem', 185000,
    'Rajutan wol tebal, cocok untuk cuaca dingin.', 12),

  ((SELECT id FROM kategori WHERE nama = 'baju'),
    'Baju Rajut Motif Garis', 165000,
    'Motif garis klasik, bahan lembut dan ringan.', 20),

  ((SELECT id FROM kategori WHERE nama = 'sweater'),
    'Sweater Rajut Oversize', 210000,
    'Potongan longgar, gaya kasual sehari-hari.', 15),

  ((SELECT id FROM kategori WHERE nama = 'sweater'),
    'Sweater Rajut Turtleneck', 225000,
    'Leher tinggi, hangat untuk musim hujan.', 8),

  ((SELECT id FROM kategori WHERE nama = 'tas'),
    'Tas Rajut Jinjing', 95000,
    'Tas jinjing serbaguna, muat untuk belanja harian.', 25),

  ((SELECT id FROM kategori WHERE nama = 'tas'),
    'Tas Rajut Selempang Mini', 78000,
    'Ukuran mini, pas untuk dompet dan ponsel.', 30),

  ((SELECT id FROM kategori WHERE nama = 'mainan'),
    'Boneka Rajut Kelinci', 55000,
    'Boneka rajut lembut, aman untuk anak-anak.', 18),

  ((SELECT id FROM kategori WHERE nama = 'mainan'),
    'Gantungan Kunci Rajut', 20000,
    'Aksesoris kecil dengan berbagai bentuk hewan.', 50);

-- ---------------------------------------------------------------------
-- LANGKAH C (opsional): cek hasilnya langsung di SQL Editor.
-- Ini contoh JOIN sederhana: menggabungkan baris dari 2 tabel yang
-- berelasi lewat kategori_id = kategori.id, supaya hasilnya menampilkan
-- NAMA kategori (bukan cuma angka id-nya).
-- ---------------------------------------------------------------------
-- SELECT
--   produk.id,
--   produk.nama,
--   kategori.nama AS kategori,   -- alias, karena kolom `nama` ada di 2 tabel
--   produk.harga,
--   produk.stok
-- FROM produk
-- INNER JOIN kategori ON produk.kategori_id = kategori.id
-- ORDER BY produk.id;
