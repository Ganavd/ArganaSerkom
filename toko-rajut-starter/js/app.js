/* =====================================================================
   app.js — SEMUA logic halaman toko: tampilkan produk, cari, filter
   kategori, dan CRUD (tambah/edit/hapus) langsung dari halaman utama.

   Tidak ada Express di sini. Semua fetch() langsung ke REST API +
   Storage Supabase (pendekatan BaaS yang sudah kita sepakati).

   INGAT: akses tambah/edit/hapus di sini TERBUKA untuk siapa saja yang
   membuka halaman ini — sengaja begini karena tujuannya latihan ujian,
   supaya banyak orang bisa saling coba fitur CRUD-nya sekaligus.
===================================================================== */

// -----------------------------------------------------------------------
// BAGIAN 0: KONFIGURASI — WAJIB DIISI dulu sebelum halaman ini jalan.
// Ambil dari Supabase Dashboard -> Project Settings -> API.
// -----------------------------------------------------------------------
const SUPABASE_URL = "https://xifikumgjyiiyabkcwbw.supabase.co";
const ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhpZmlrdW1nanlpaXlhYmtjd2J3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MTAzODAsImV4cCI6MjEwNDE4NjM4MH0.y_EnjcwlsBDY7vx0tbBWqBIhCLZVrdlhrevjBp0Hv9g";

const HEADERS_JSON = {
  apikey: ANON_KEY,
  Authorization: `Bearer ${ANON_KEY}`,
  "Content-Type": "application/json",
  Prefer: "return=representation",
};

// -----------------------------------------------------------------------
// ELEMEN: form TAMBAH (accordion, khusus produk baru)
// -----------------------------------------------------------------------
const btnToggleForm = document.getElementById("btn-toggle-form");
const chevronIcon = document.getElementById("chevron-icon");
const addPanel = document.getElementById("add-panel");

const formTambah = document.getElementById("form-tambah");
const tambahNama = document.getElementById("tambah-nama");
const tambahKategori = document.getElementById("tambah-kategori");
const tambahHarga = document.getElementById("tambah-harga");
const tambahDeskripsi = document.getElementById("tambah-deskripsi");
const tambahGambarUrl = document.getElementById("tambah-gambar-url");
const tambahGambar = document.getElementById("tambah-gambar");
const tambahPreview = document.getElementById("tambah-preview");
const tambahSubmit = document.getElementById("tambah-submit");
const tambahStatus = document.getElementById("tambah-status");

// -----------------------------------------------------------------------
// ELEMEN: form EDIT (pop up, khusus mengubah produk yang sudah ada)
// -----------------------------------------------------------------------
const modalEdit = document.getElementById("modal-edit");
const btnTutupEdit = document.getElementById("btn-tutup-edit");

const formEdit = document.getElementById("form-edit");
const editId = document.getElementById("edit-id");
const editNama = document.getElementById("edit-nama");
const editKategori = document.getElementById("edit-kategori");
const editHarga = document.getElementById("edit-harga");
const editDeskripsi = document.getElementById("edit-deskripsi");
const editGambarUrl = document.getElementById("edit-gambar-url");
const editGambar = document.getElementById("edit-gambar");
const editPreview = document.getElementById("edit-preview");
const editSubmit = document.getElementById("edit-submit");
const editStatus = document.getElementById("edit-status");

// -----------------------------------------------------------------------
// ELEMEN: pop up konfirmasi hapus
// -----------------------------------------------------------------------
const modalHapus = document.getElementById("modal-hapus");
const btnTutupHapus = document.getElementById("btn-tutup-hapus");
const btnBatalHapus = document.getElementById("btn-batal-hapus");
const btnKonfirmasiHapus = document.getElementById("btn-konfirmasi-hapus");

// -----------------------------------------------------------------------
// ELEMEN: pop up detail produk
// -----------------------------------------------------------------------
const modalDetail = document.getElementById("modal-detail");
const btnTutupDetail = document.getElementById("btn-tutup-detail");
const detailGambarImg = document.getElementById("detail-gambar-img");
const detailLinkUnduh = document.getElementById("detail-link-unduh");
const detailKategori = document.getElementById("detail-kategori");
const detailNama = document.getElementById("detail-nama");
const detailHarga = document.getElementById("detail-harga");
const detailDeskripsi = document.getElementById("detail-deskripsi");

// -----------------------------------------------------------------------
// ELEMEN: toolbar & grid produk
// -----------------------------------------------------------------------
const inputCari = document.getElementById("input-cari");
const filterKategori = document.getElementById("filter-kategori");
const productGrid = document.getElementById("product-grid");
const emptyMsg = document.getElementById("empty-msg");

let semuaProduk = [];
let idYangMauDihapus = null;

/* =====================================================================
   BAGIAN 1: FUNGSI BUKA/TUTUP POP UP — dipakai berulang untuk semua
   pop up (edit, hapus, detail).
===================================================================== */
function bukaModal(elModal) {
  elModal.classList.remove("is-hidden");
}
function tutupModal(elModal) {
  elModal.classList.add("is-hidden");
}

// Klik area gelap di luar kotak modal -> ikut menutup modal itu.
[modalEdit, modalHapus, modalDetail].forEach((elModal) => {
  elModal.addEventListener("click", (event) => {
    if (event.target === elModal) tutupModal(elModal);
  });
});

/* =====================================================================
   BAGIAN 2: PANEL TAMBAH PRODUK (accordion) — cuma untuk produk BARU.
===================================================================== */
btnToggleForm.addEventListener("click", () => {
  addPanel.classList.toggle("is-closed");
  chevronIcon.classList.toggle("is-open");

  if (!addPanel.classList.contains("is-closed")) {
    tambahNama.focus();
  }
});

/* =====================================================================
   BAGIAN 3: KATEGORI — isi 3 dropdown sekaligus (filter, tambah, edit).
===================================================================== */
async function muatKategori() {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/kategori?select=id,nama,slug&order=nama`, {
    headers: HEADERS_JSON,
  });
  const data = await res.json();

  const opsiById = data.map((k) => `<option value="${k.id}">${k.nama}</option>`).join("");
  tambahKategori.innerHTML = opsiById;
  editKategori.innerHTML = opsiById;

  filterKategori.innerHTML =
    `<option value="">Semua kategori</option>` +
    data.map((k) => `<option value="${k.slug}">${k.nama}</option>`).join("");
}

/* =====================================================================
   BAGIAN 4: AMBIL PRODUK — embed relasi kategori(nama,slug), hasilnya
   mirip JOIN tanpa nulis SQL JOIN (fitur bawaan PostgREST/Supabase).
===================================================================== */
async function muatProduk() {
  const res = await fetch(
    `${SUPABASE_URL}/rest/v1/produk?select=id,nama,harga,deskripsi,gambar_url,kategori_id,kategori(nama,slug)&order=id`,
    { headers: HEADERS_JSON }
  );
  semuaProduk = await res.json();
  renderProduk();
}

/* =====================================================================
   BAGIAN 5: RENDER KARTU + terapkan search & filter kategori.
===================================================================== */
function renderProduk() {
  const kataKunci = inputCari.value.trim().toLowerCase();
  const slugTerpilih = filterKategori.value;

  const hasil = semuaProduk.filter((p) => {
    const cocokNama = p.nama.toLowerCase().includes(kataKunci);
    const cocokKategori = !slugTerpilih || p.kategori?.slug === slugTerpilih;
    return cocokNama && cocokKategori;
  });

  emptyMsg.style.display = hasil.length === 0 ? "block" : "none";

  productGrid.innerHTML = hasil
    .map(
      (p) => `
      <div class="product-card" onclick="bukaDetail(${p.id})">
        <div class="card-actions">
          <!-- stopPropagation() supaya klik pensil/silang tidak ikut
               memicu onclick kartu (buka detail). -->
          <button type="button" title="Edit" onclick="event.stopPropagation(); bukaEdit(${p.id})">&#9998;</button>
          <button type="button" title="Hapus" onclick="event.stopPropagation(); mintaKonfirmasiHapus(${p.id})">&times;</button>
        </div>
        <div class="product-thumb">
          ${p.gambar_url ? `<img src="${p.gambar_url}" alt="${p.nama}" />` : `<span class="placeholder">Belum ada foto</span>`}
        </div>
        <div class="product-body">
          <span class="category-tag">${p.kategori?.nama ?? "-"}</span>
          <h3>${p.nama}</h3>
          <span class="price">Rp${Number(p.harga).toLocaleString("id-ID")}</span>
        </div>
      </div>`
    )
    .join("");
}

inputCari.addEventListener("input", renderProduk);
filterKategori.addEventListener("change", renderProduk);

/* =====================================================================
   BAGIAN 6: POP UP DETAIL PRODUK — dipanggil saat kartu diklik.
===================================================================== */
function bukaDetail(id) {
  const p = semuaProduk.find((item) => item.id === id);
  if (!p) return;

  detailKategori.textContent = p.kategori?.nama ?? "-";
  detailNama.textContent = p.nama;
  detailHarga.textContent = "Rp" + Number(p.harga).toLocaleString("id-ID");
  detailDeskripsi.textContent = p.deskripsi || "Belum ada deskripsi untuk produk ini.";

  if (p.gambar_url) {
    detailGambarImg.src = p.gambar_url;
    detailLinkUnduh.href = p.gambar_url;
    detailLinkUnduh.setAttribute("download", `${p.nama}.jpg`);
    detailLinkUnduh.style.display = "block";
  } else {
    detailGambarImg.src = "";
    detailLinkUnduh.style.display = "none";
  }

  bukaModal(modalDetail);
}

btnTutupDetail.addEventListener("click", () => tutupModal(modalDetail));

/* =====================================================================
   BAGIAN 7: PREVIEW GAMBAR — dipasang di KEDUA form (tambah & edit).
   Ditulis 1x sebagai fungsi, dipakai untuk 2 pasang elemen berbeda.
===================================================================== */
function pasangPreview(inputFile, imgPreview, inputUrl) {
  inputFile.addEventListener("change", () => {
    const file = inputFile.files[0];
    if (!file) {
      const url = inputUrl.value.trim();
      imgPreview.src = url;
      imgPreview.style.display = url ? "block" : "none";
      return;
    }
    imgPreview.src = URL.createObjectURL(file);
    imgPreview.style.display = "block";
  });
}
pasangPreview(tambahGambar, tambahPreview, tambahGambarUrl);
pasangPreview(editGambar, editPreview, editGambarUrl);

function pasangPreviewUrl(inputUrl, inputFile, imgPreview) {
  inputUrl.addEventListener("input", () => {
    if (inputFile.files[0]) return;
    const url = inputUrl.value.trim();
    imgPreview.src = url;
    imgPreview.style.display = url ? "block" : "none";
  });
}
pasangPreviewUrl(tambahGambarUrl, tambahGambar, tambahPreview);
pasangPreviewUrl(editGambarUrl, editGambar, editPreview);

/* =====================================================================
   BAGIAN 8: UPLOAD GAMBAR ke Supabase Storage (PNG atau JPG).
   1 fungsi ini dipakai oleh form tambah MAUPUN form edit.
===================================================================== */
async function uploadGambarKeStorage(file) {
  const tipeDiizinkan = ["image/png", "image/jpeg"];
  if (!tipeDiizinkan.includes(file.type)) {
    throw new Error("Foto harus berformat PNG atau JPG.");
  }

  const namaFile = `${Date.now()}-${file.name}`;

  const res = await fetch(`${SUPABASE_URL}/storage/v1/object/produk-images/${namaFile}`, {
    method: "POST",
    headers: {
      apikey: ANON_KEY,
      Authorization: `Bearer ${ANON_KEY}`,
      "Content-Type": file.type,
    },
    body: file,
  });

  if (!res.ok) throw new Error("Upload foto gagal (status " + res.status + ")");

  return `${SUPABASE_URL}/storage/v1/object/public/produk-images/${namaFile}`;
}

/* =====================================================================
   BAGIAN 9: FORM TAMBAH — submit handler-nya SENDIRI, cuma bisa POST
   (bikin baris baru), tidak pernah PATCH.
===================================================================== */
formTambah.addEventListener("submit", async (event) => {
  event.preventDefault();
  tambahSubmit.disabled = true;
  tambahStatus.textContent = "Menyimpan...";
  tambahStatus.style.color = "#2e7d32";

  try {
    let gambarUrl = tambahGambarUrl.value.trim();
    const file = tambahGambar.files[0];
    if (file) gambarUrl = await uploadGambarKeStorage(file);

    const bodyData = {
      nama: tambahNama.value,
      kategori_id: Number(tambahKategori.value),
      harga: Number(tambahHarga.value),
      deskripsi: tambahDeskripsi.value,
      ...(gambarUrl ? { gambar_url: gambarUrl } : {}),
    };

    const res = await fetch(`${SUPABASE_URL}/rest/v1/produk`, {
      method: "POST",
      headers: HEADERS_JSON,
      body: JSON.stringify(bodyData),
    });

    if (!res.ok) throw new Error("Gagal menyimpan (status " + res.status + ")");

    tambahStatus.textContent = "Produk berhasil ditambahkan.";
    formTambah.reset();
    tambahPreview.style.display = "none";
    await muatProduk();
  } catch (err) {
    console.error(err);
    tambahStatus.textContent = err.message;
    tambahStatus.style.color = "#c0392b";
  } finally {
    tambahSubmit.disabled = false;
  }
});

/* =====================================================================
   BAGIAN 10: FORM EDIT — submit handler-nya SENDIRI, selalu PATCH
   (pakai edit-id untuk tahu baris mana yang diubah).
===================================================================== */
function bukaEdit(id) {
  const produk = semuaProduk.find((p) => p.id === id);
  if (!produk) return;

  editId.value = produk.id;
  editNama.value = produk.nama;
  editKategori.value = produk.kategori_id;
  editHarga.value = produk.harga;
  editDeskripsi.value = produk.deskripsi ?? "";
  editGambarUrl.value = produk.gambar_url ?? "";
  editStatus.textContent = "";
  editGambar.value = "";

  if (produk.gambar_url) {
    editPreview.src = produk.gambar_url;
    editPreview.style.display = "block";
  } else {
    editPreview.style.display = "none";
  }

  bukaModal(modalEdit);
}

btnTutupEdit.addEventListener("click", () => tutupModal(modalEdit));

formEdit.addEventListener("submit", async (event) => {
  event.preventDefault();
  editSubmit.disabled = true;
  editStatus.textContent = "Menyimpan...";
  editStatus.style.color = "#2e7d32";

  try {
    let gambarUrl = editGambarUrl.value.trim();
    const file = editGambar.files[0];
    if (file) gambarUrl = await uploadGambarKeStorage(file);

    const bodyData = {
      nama: editNama.value,
      kategori_id: Number(editKategori.value),
      harga: Number(editHarga.value),
      deskripsi: editDeskripsi.value,
      ...(gambarUrl ? { gambar_url: gambarUrl } : {}),
    };

    const res = await fetch(`${SUPABASE_URL}/rest/v1/produk?id=eq.${editId.value}`, {
      method: "PATCH",
      headers: HEADERS_JSON,
      body: JSON.stringify(bodyData),
    });

    if (!res.ok) throw new Error("Gagal menyimpan (status " + res.status + ")");

    editStatus.textContent = "Produk berhasil diubah.";
    await muatProduk();
    // Pop up ditutup sedikit belakangan, biar pesan "berhasil" sempat
    // kelihatan dulu sebelum hilang.
    setTimeout(() => tutupModal(modalEdit), 700);
  } catch (err) {
    console.error(err);
    editStatus.textContent = err.message;
    editStatus.style.color = "#c0392b";
  } finally {
    editSubmit.disabled = false;
  }
});

/* =====================================================================
   BAGIAN 11: POP UP KONFIRMASI HAPUS
===================================================================== */
function mintaKonfirmasiHapus(id) {
  idYangMauDihapus = id;
  bukaModal(modalHapus);
}

btnTutupHapus.addEventListener("click", () => tutupModal(modalHapus));
btnBatalHapus.addEventListener("click", () => tutupModal(modalHapus));

btnKonfirmasiHapus.addEventListener("click", async () => {
  if (idYangMauDihapus === null) return;

  const res = await fetch(`${SUPABASE_URL}/rest/v1/produk?id=eq.${idYangMauDihapus}`, {
    method: "DELETE",
    headers: HEADERS_JSON,
  });

  tutupModal(modalHapus);

  if (!res.ok) {
    alert("Gagal menghapus (status " + res.status + ")");
    return;
  }

  idYangMauDihapus = null;
  await muatProduk();
});

/* =====================================================================
   BAGIAN 12: JALANKAN SAAT HALAMAN DIBUKA
===================================================================== */
muatKategori();
muatProduk();