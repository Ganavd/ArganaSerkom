// =====================================================================
// server.js — VERSI ROMBAKAN, menyesuaikan skema baru (kategori + produk
// yang berelasi lewat FOREIGN KEY). db.js TIDAK PERLU DIUBAH SAMA SEKALI —
// itu keuntungan dari pola "satu file khusus untuk koneksi": perubahan
// skema tabel tidak pernah menyentuh cara kita konek ke database.
// =====================================================================
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import pool from "./db.js";

dotenv.config();

const app = express();
app.use(cors());

// -----------------------------------------------------------------------
// GET /api/categories
// Endpoint BARU. Berguna untuk mengisi filter bar di frontend secara
// dinamis dari database, bukan ditulis manual di HTML/JS.
// -----------------------------------------------------------------------
app.get("/api/categories", async (req, res) => {
  try {
    const result = await pool.query("SELECT id, nama, slug FROM kategori ORDER BY nama");
    res.json(result.rows);
  } catch (error) {
    console.error("Gagal mengambil data kategori:", error.message);
    res.status(500).json({ error: "Gagal mengambil data kategori dari database." });
  }
});

// -----------------------------------------------------------------------
// GET /api/products
// PERUBAHAN UTAMA dari versi lama: dulu cukup "SELECT * FROM produk"
// karena nama kategori ada langsung di tabel produk. Sekarang kategori
// ada di tabel TERPISAH, jadi kita WAJIB pakai JOIN supaya hasilnya
// tetap menyertakan nama kategori yang mudah dibaca (bukan cuma angka
// kategori_id).
//
// Query string opsional: /api/products?kategori=sweater
// (dipakai kalau mau filter dari sisi server, bukan cuma di frontend)
// -----------------------------------------------------------------------
app.get("/api/products", async (req, res) => {
  try {
    const { kategori } = req.query; // contoh: ?kategori=sweater

    // Query dasar: JOIN produk dengan kategori lewat kategori_id = kategori.id.
    //
    // Perhatikan alias-alias "AS nama_baru" di bawah: kolom di database
    // tetap ditulis dalam Bahasa Indonesia (nama, harga, deskripsi) supaya
    // konsisten dengan skema SQL yang kita pelajari. Tapi app.js (frontend
    // lama) sudah terlanjur menulis item.name / item.price / item.desc /
    // item.category. Daripada mengubah app.js, kita "jembatani" bedanya
    // di sini lewat alias — konsep ini disebut membentuk "API contract"
    // yang stabil untuk frontend, walau nama kolom di database berbeda.
    let sql = `
      SELECT
        produk.id,
        produk.nama        AS name,
        kategori.nama       AS category,
        kategori.slug       AS category_slug,
        produk.harga        AS price,
        produk.deskripsi    AS desc,
        produk.stok         AS stock
      FROM produk
      INNER JOIN kategori ON produk.kategori_id = kategori.id
    `;
    const params = [];

    // Filter opsional berdasarkan slug kategori. Pakai PARAMETERIZED QUERY
    // ($1) — BUKAN menyambung string manual — supaya aman dari SQL Injection.
    if (kategori) {
      sql += " WHERE kategori.slug = $1";
      params.push(kategori);
    }

    sql += " ORDER BY produk.id";

    const result = await pool.query(sql, params);
    res.json(result.rows);
  } catch (error) {
    console.error("Gagal mengambil data produk:", error.message);
    res.status(500).json({ error: "Gagal mengambil data produk dari database." });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server jalan di http://localhost:${PORT}`);
});
