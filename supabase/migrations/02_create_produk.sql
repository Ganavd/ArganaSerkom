-- =====================================================================
-- FILE 2 dari 3 — jalankan SETELAH 01_create_kategori.sql
-- =====================================================================

-- Ini versi ROMBAKAN dari tabel `produk` lama.
-- SEBELUMNYA:  kategori VARCHAR(50) NOT NULL   -> teks bebas
-- SEKARANG:    kategori_id INT REFERENCES kategori(id)  -> FOREIGN KEY
--
-- Kalau tabel `produk` versi lama sudah pernah kamu buat & isi data,
-- jalankan dulu baris di bawah ini untuk membersihkan struktur lama
-- sebelum membuat yang baru (aman dijalankan walau tabelnya belum ada,
-- karena pakai IF EXISTS). Uncomment kalau memang mau reset total:
-- DROP TABLE IF EXISTS produk;

CREATE TABLE IF NOT EXISTS produk (
  id SERIAL PRIMARY KEY,

  -- ==== INI INTI PEMBELAJARAN FOREIGN KEY (FK) ====
  -- kategori_id menyimpan ANGKA yang merujuk ke id di tabel kategori.
  -- REFERENCES kategori(id) artinya: Postgres akan MENOLAK insert/update
  -- kalau angka yang dimasukkan di sini tidak ada di tabel kategori.
  -- Ini yang disebut "referential integrity" — database sendiri yang
  -- menjaga data tetap konsisten, bukan aplikasi (JS) yang harus rajin
  -- mengecek manual.
  --
  -- ON DELETE RESTRICT = kalau ada yang coba menghapus sebuah kategori
  -- padahal masih dipakai oleh produk, Postgres akan MENOLAK penghapusan
  -- itu (lempar error) daripada diam-diam menghapus produk juga.
  -- Ini pilihan paling aman untuk data toko: kategori tidak boleh hilang
  -- begitu saja kalau masih ada produk yang menempel di dalamnya.
  -- (Alternatif lain yang sering dipakai di proyek lain: ON DELETE CASCADE
  -- yang otomatis ikut menghapus produk-produknya — TIDAK dipakai di sini
  -- karena berisiko untuk data toko.)
  kategori_id INT NOT NULL REFERENCES kategori(id) ON DELETE RESTRICT,

  nama VARCHAR(150) NOT NULL,

  -- CHECK = aturan tambahan di level database: harga tidak boleh negatif.
  -- Ini "jaring pengaman" kedua — walau nanti di kode Express juga
  -- sebaiknya divalidasi, database tetap menolak kalau ada yang lolos.
  harga INT NOT NULL CHECK (harga >= 0),

  deskripsi TEXT,

  -- Kolom baru (tidak ada di versi lama): stok barang.
  -- DEFAULT 0 = kalau saat INSERT kolom ini tidak diisi, otomatis jadi 0.
  stok INT NOT NULL DEFAULT 0 CHECK (stok >= 0),

  dibuat_pada TIMESTAMP NOT NULL DEFAULT NOW()
);

-- INDEX tambahan (opsional tapi praktik baik): karena kita akan sering
-- mencari/filter produk berdasarkan kategori_id (mis. "tampilkan semua
-- produk kategori sweater"), index di kolom ini bikin pencarian lebih
-- cepat saat data sudah banyak. Untuk data kecil sekarang efeknya belum
-- terasa, tapi ini kebiasaan yang bagus dari awal.
CREATE INDEX IF NOT EXISTS idx_produk_kategori_id ON produk (kategori_id);
