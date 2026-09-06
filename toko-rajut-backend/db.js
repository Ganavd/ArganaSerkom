// =====================================================================
// db.js — satu-satunya tempat yang tahu cara konek ke database.
// File lain (server.js) tinggal "pakai" pool ini, tidak perlu tahu
// detail host/password. Ini contoh konkret "organisasi file yang rapi".
//
// Ini persis pola yang sudah kamu pakai di proyek Supabase sebelumnya:
// Pool dari 'pg', dikonfigurasi lewat connectionString di .env.
// =====================================================================
import { Pool } from "pg";
import dotenv from "dotenv";

dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }, // Supabase mewajibkan koneksi SSL
});

export default pool;

