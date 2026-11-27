# Debugging Cheatsheet — SiRUNA UBBG

Pertemuan 11 · Flutter / Laravel / MySQL

| Gejala | Lapisan | Cek pertama | Cek kedua |
|---|---|---|---|
| Server tidak dapat dihubungi | Integrasi | Periksa URL API dan jalankan `adb devices`; emulator Android menggunakan `10.0.2.2` untuk mengakses host. | Pastikan Laravel berjalan pada port yang benar. Periksa `adb reverse --list` dan log request. Bedakan kegagalan koneksi dari respons HTTP. |
| HTTP 401 | Autentikasi | Periksa keberadaan token dan header Authorization tanpa mencetak nilai token. | Uji endpoint profile melalui Postman dengan token sah; periksa sesi yang kedaluwarsa atau telah dicabut. |
| HTTP 422 | Validasi API | Periksa body respons, terutama objek `errors`, serta nama field dan format tanggal. | Bandingkan payload Flutter dengan aturan FormRequest Laravel; pastikan pesan tampil pada kolom terkait. |
| Booking lintas kamar bertumpang tindih | Backend | Periksa filter user_id, status aktif dan kondisi overlap pada controller. | Query bookings berdasarkan user_id; pisahkan aturan periode per mahasiswa dari kapasitas per kamar. |
| Data sukses di UI tetapi tidak tersimpan | Database/API | Periksa status HTTP dan isi respons pada request create. | Query tabel terkait; periksa transaksi dan log Laravel. Jangan menganggap snackbar sukses sebagai bukti penyimpanan. |
| Ingat Saya tidak berfungsi | Frontend | Telusuri nilai checkbox sampai ke fungsi login dan repository. | Periksa penyimpanan token serta jalankan stop/run dengan kedua pilihan checkbox. Uji logout secara terpisah. |
| PHP tidak dikenali terminal | Lingkungan | Jalankan `php -v` di terminal Laragon; cek PATH jika memakai PowerShell. | Gunakan executable PHP yang sesuai proyek; jalankan `php -l` sebelum uji Laravel. |
| Tampilan lama setelah perubahan | Frontend | Periksa file yang diubah dan jalankan Flutter Analyzer. | Lakukan hot restart atau stop/run sesuai jenis perubahan; verifikasi perilaku, bukan hanya tampilan. |

**SOP ringkas:** reproduksi gejala dengan input yang dapat diulang; isolasi lapisan menggunakan bukti; tulis hipotesis yang dapat diuji; konsultasikan solusi dengan konteks dan potongan kode relevan; terapkan perubahan kecil lalu uji ulang dan dokumentasikan hasil. Jika hipotesis tidak cocok dengan bukti, kembali ke investigasi. Catat hasil gagal maupun berhasil. Gunakan screenshot sebelum dan sesudah, status HTTP bila tersedia, serta query database untuk membuktikan efek perubahan. Jangan menghapus data historis hanya agar pengujian tampak berhasil.

**Format prompt AI:** konteks teknologi dan lingkungan, masalah aktual, langkah reproduksi, hasil investigasi, hipotesis sementara, kode relevan, serta permintaan solusi minimal dan cara verifikasi. Minta AI menunjukkan bukti pendukung dan menyatakan hal yang belum diketahui. Hindari mengirim password, token, file `.env`, atau data pribadi ke layanan publik. Selalu tinjau diff sebelum commit dan pisahkan perbaikan tiap bug. Catat keterbatasan pengujian, misalnya belum menguji konkurensi atau perangkat fisik. Gunakan hasil pengujian nyata sebagai dasar laporan, bukan prediksi AI.
