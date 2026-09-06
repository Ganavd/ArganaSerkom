INSERT INTO kategori (nama, slug) VALUES
  ('baju', 'baju'),
  ('sweater', 'sweater'),
  ('tas', 'tas'),
  ('mainan', 'mainan')
ON CONFLICT (nama) DO NOTHING;

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
