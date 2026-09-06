-- =====================================================================
-- FILE 1 dari 3 — urutan menjalankan file ITU PENTING:
--   01_create_kategori.sql   <- jalankan ini duluan
--   02_create_produk.sql     <- lalu ini
--   03_seed_data.sql         <- baru ini (isi data dummy)
--
-- KENAPA URUTANNYA HARUS BEGINI?
-- Karena nanti tabel `produk` akan punya kolom yang "menunjuk" ke tabel
-- `kategori` (namanya FOREIGN KEY). Postgres tidak akan izinkan kita
-- membuat "penunjuk" ke tabel yang belum ada. Makanya tabel yang
-- DITUNJUK (kategori) harus dibuat lebih dulu daripada tabel yang
-- MENUNJUK (produk).
--
-- CARA PAKAI: Supabase Dashboard -> SQL Editor -> New query -> paste -> Run.
-- Atau kalau kamu pakai Supabase CLI: taruh file ini di folder
-- supabase/migrations/ dengan prefix timestamp, lalu `supabase db push`.
-- =====================================================================

-- Kenapa tabel terpisah, tidak digabung jadi 1 kolom teks di produk (seperti
-- schema versi lama: kategori VARCHAR)?
-- Karena kalau kategori cuma teks bebas, tidak ada yang mencegah orang
-- menulis "Baju", "baju", " baju" (beda spasi/kapital) untuk kategori yang
-- SAMA — data jadi berantakan & susah di-filter. Dengan tabel kategori
-- sendiri, tiap kategori cuma didefinisikan SEKALI, lalu produk lain
-- tinggal "pinjam" lewat ID-nya. Konsep ini namanya NORMALISASI.
CREATE TABLE IF NOT EXISTS kategori (
  -- SERIAL = tipe angka yang otomatis naik sendiri (1, 2, 3, ...) tiap
  -- ada baris baru. Setara AUTO_INCREMENT di MySQL.
  -- PRIMARY KEY = "identitas unik" baris ini. Tidak boleh kembar,
  -- tidak boleh kosong (NULL) walau tidak ditulis eksplisit.
  id SERIAL PRIMARY KEY,

  -- UNIQUE = tidak boleh ada 2 baris dengan nilai `nama` yang sama persis.
  -- Ini mencegah kategori "baju" ditambahkan dua kali secara tidak sengaja.
  nama VARCHAR(50) NOT NULL UNIQUE,

  -- `slug` = versi nama yang aman dipakai di URL (huruf kecil, spasi jadi
  -- strip). Contoh: nama "Tas Rajut" -> slug "tas-rajut". Ini pola umum
  -- di dunia web dev, walau untuk produk toko rajut ini masih sederhana
  -- (kategorinya cuma satu kata), tetap dibuatkan supaya kamu terbiasa
  -- dengan konsep ini untuk proyek yang lebih besar nanti.
  slug VARCHAR(50) NOT NULL UNIQUE,

  -- TIMESTAMP + DEFAULT NOW() = kolom ini otomatis diisi "waktu sekarang"
  -- saat baris dibuat, tanpa kita perlu menulis nilainya manual di INSERT.
  dibuat_pada TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Catatan pembelajaran tambahan:
-- IF NOT EXISTS -> supaya kalau file ini tidak sengaja dijalankan 2x,
-- Postgres tidak error "tabel sudah ada", cukup dilewati saja.
