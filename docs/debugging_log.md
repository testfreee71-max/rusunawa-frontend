# Debugging Log — Pertemuan 11

**Proyek:** SiRUNA UBBG (RUSUNAWA) · **Tanggal:** 27 November 2026  
**Penyusun:** Yahdi Abdan — 23210120  
**Branch:** `fix/pertemuan-11` (frontend dan backend)

Dokumentasi retrospektif atas pengujian nyata pada Flutter, Laravel dan MySQL lokal. Investigasi dan hipotesis dibahas bersama AI; tidak diklaim seluruh hipotesis ditulis mandiri sebelum konsultasi AI.

## BUG-01 — Koneksi API emulator (integrasi)

1. **Masalah dan reproduksi:** Jalankan aplikasi pada emulator Android lalu login. Snackbar menyatakan server tidak dapat dihubungi.
2. **Isolasi:** Periksa daftar perangkat ADB, konfigurasi URL API dan log Laravel. Terdapat emulator offline dan emulator aktif; penggunaan localhost pada emulator bergantung pada forwarding.
3. **Hipotesis:** Alamat loopback emulator tidak langsung menuju host Laravel. Hipotesis sesuai konfigurasi URL dan gejala koneksi.
4. **Solusi:** Ubah default URL API dari `127.0.0.1:8000/api/` menjadi `10.0.2.2:8000/api/`. Pertahankan override `API\_BASE\_URL`. Commit frontend [`23cdd33`](https://github.com/testfreee71-max/rusunawa-frontend/commit/23cdd33).
5. **Verifikasi dan pelajaran:** `adb reverse --list` kosong saat diperiksa; login dan daftar kamar berhasil ditampilkan. Gunakan alamat host yang sesuai lingkungan perangkat. Perangkat fisik tetap memerlukan konfigurasi URL tersendiri. Tidak ada uji ulang HTTP independen untuk setiap endpoint pada tahap ini.

!\[Before: kegagalan koneksi, kredensial disensor](screenshots/bug01\_before.png)

!\[After: daftar kamar tampil](screenshots/bug01\_after.png)

## BUG-02 — Pemesanan bentrok lintas kamar (backend/API)

1. **Masalah dan reproduksi:** Database menunjukkan mahasiswa user ID 1 memiliki booking ID 1 (A101, 1 Januari–1 April 2027) dan ID 7 (A102, 10 Januari–10 April 2027), keduanya waiting. Periode bertumpang tindih.
2. **Isolasi:** Query MySQL terhadap bookings dan rooms; baca `RusunawaController::createBooking`. Query lama membatasi pencarian bentrok pada kamar yang sama sebelum memfilter user.
3. **Hipotesis:** Filter room\_id menyebabkan bentrok lintas kamar tidak terdeteksi. Aturan yang digunakan: satu mahasiswa tidak boleh memiliki dua pemesanan aktif yang bertumpang tindih, terlepas dari kamar.
4. **Solusi:** Periksa overlap berdasarkan user\_id dan status waiting/processing/approved, dengan start\_date < tanggal akhir baru dan end\_date > tanggal awal baru. Pertahankan pemeriksaan kapasitas per kamar. Gunakan transaksi dan penguncian baris user serta room. Commit backend [`28c72dd`](https://github.com/testfreee71-max/rusunawa-backend/commit/28c72dd).
5. **Verifikasi dan pelajaran:** PHP lint tidak menemukan kesalahan syntax. Pengajuan A101 5 Februari–5 Maret 2027 ditolak. Pengajuan A101 2–9 April 2027 juga ditolak meski booking A101 lama telah berakhir; booking A102 masih aktif. UI menampilkan pesan pada kolom tanggal masuk dan snackbar. Query akhir tetap menghasilkan ID 1 dan 7. Pisahkan validasi bisnis per pengguna dari kapasitas kamar. Data historis tidak dihapus; uji konkurensi dan pengambilan status HTTP langsung belum dilakukan.

!\[Before: dua booking bertumpang tindih](screenshots/bug02\_before.png)

!\[After: pengajuan lintas kamar ditolak](screenshots/bug02\_after.png)

!\[After: tidak ada booking baru](screenshots/bug02\_database\_after.png)

## BUG-03 — Ingat Saya tidak mengendalikan sesi (frontend)

1. **Masalah dan reproduksi:** Logout, login tanpa mencentang Ingat Saya, stop debugging dan run kembali. Pengguna melaporkan aplikasi langsung masuk Beranda.
2. **Isolasi:** Periksa LoginScreen, AppState, AuthRepository dan TokenStorage. Checkbox hanya mengubah `\_rememberMe`; fungsi login tidak menerima nilainya. Repository selalu menyimpan token ke FlutterSecureStorage.
3. **Hipotesis:** Preferensi checkbox tidak diteruskan ke lapisan penyimpanan sehingga semua login menjadi persisten.
4. **Solusi:** Teruskan parameter `rememberMe` dari LoginScreen ke AppState dan AuthRepository. TokenStorage menyimpan token di memori untuk sesi nonpersisten dan di SecureStorage untuk sesi persisten. Logout menghapus keduanya; registrasi mempertahankan perilaku lama. Commit frontend [`0788492`](https://github.com/testfreee71-max/rusunawa-frontend/commit/0788492).
5. **Verifikasi dan pelajaran:** Flutter Analyzer menampilkan 30 info tanpa error/warning. Tanpa centang, restart kembali ke Login; dengan centang, restart langsung ke Beranda; setelah logout dan restart, kembali ke Login. Uji perilaku sesi dengan stop/run, bukan hot reload.

**Before:** reproduksi dikonfirmasi pengguna melalui chat; screenshot khusus kondisi sebelum fix belum teridentifikasi. Jangan mengganti bukti sebelum dengan screenshot setelah perbaikan.

!\[After: sesi nonpersisten kembali ke Login](screenshots/bug03\_after.png)

!\[After: sesi persisten langsung ke Beranda](screenshots/bug03\_remember\_me\_pass.png)

!\[After: logout kembali ke Login](screenshots/bug03\_logout\_pass.png)

## Status

Tiga commit perbaikan tercatat lokal. Push, PR, review anggota lain dan merge belum dikonfirmasi. Bukti visual mencakup delapan screenshot, tetapi screenshot BEFORE khusus BUG-03 masih perlu dilengkapi melalui reproduksi versi lama. Commit backend juga mengandung perubahan format kode; pengujian yang dicatat terbatas pada skenario di atas.



\## Bukti Tambahan BUG-03



Pengujian BEFORE direkonstruksi pada 27 November 2026 menggunakan Git Worktree pada commit 23cdd33, yaitu versi sebelum perbaikan Remember Me.



Pengguna login tanpa mencentang Ingat Saya. Setelah aplikasi dihentikan dan dijalankan ulang, aplikasi langsung masuk Beranda.



Hasil: bug berhasil direproduksi.



!\[BEFORE BUG-03](screenshots/bug03\_before.png)



Perbaikan pada commit 0788492 telah berhasil mengatasi masalah tersebut.



