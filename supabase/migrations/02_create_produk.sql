CREATE TABLE IF NOT EXISTS produk (
  id SERIAL PRIMARY KEY,
  kategori_id INT NOT NULL REFERENCES kategori(id) ON DELETE RESTRICT,
  nama VARCHAR(150) NOT NULL,
  harga INT NOT NULL CHECK (harga >= 0),
  deskripsi TEXT,
  stok INT NOT NULL DEFAULT 0 CHECK (stok >= 0),
  dibuat_pada TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_produk_kategori_id ON produk (kategori_id);
