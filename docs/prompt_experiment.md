# Prompt Experiment — Pertemuan 11

**Proyek:** SIRUNAU UBBG | **Tanggal:** 27 November 2026  
**Kasus:** BUG-03 — Remember Me | **Commit implementasi:** `0788492`

Eksperimen retrospektif menggunakan dua sesi ChatGPT terpisah setelah perbaikan, dengan kode sebelum perbaikan. Versi model dan pengaturan kedua sesi tidak dicatat. Respons berikut berasal dari teks yang dikirim pengguna; CSS diagram yang ikut tersalin dibuang, label diagram dipertahankan.

## Prompt A — Poor Prompt

> Fitur Ingat Saya pada halaman login Flutter tidak berfungsi. Bagaimana cara memperbaikinya?

## Prompt B — Good Prompt

Saya sedang mengembangkan aplikasi SIRUNAU UBBG menggunakan Flutter sebagai frontend, Laravel REST API sebagai backend, MySQL sebagai database, dan Laravel Sanctum untuk autentikasi.

**1. Deskripsi masalah**

Fitur Ingat Saya (Remember Me) pada halaman login tidak berfungsi. Ketika pengguna login tanpa mencentang Ingat Saya, aplikasi tetap masuk ke Beranda setelah ditutup dan dijalankan ulang.

**2. Perilaku yang diharapkan**

- Jika Ingat Saya dicentang, sesi login dipertahankan.
- Jika tidak dicentang, pengguna harus login kembali setelah aplikasi dihentikan dan dijalankan ulang.
- Logout harus menghapus sesi pengguna.

**3. Hasil investigasi**

- Login API berhasil.
- Bug berhasil direproduksi menggunakan Android Emulator.
- Checkbox dapat dicentang dan dihilangkan centangnya.
- Aplikasi menggunakan flutter_secure_storage.
- Nilai checkbox tidak diteruskan ke fungsi autentikasi.

**4. Hipotesis**

Token autentikasi selalu disimpan secara permanen tanpa memperhatikan nilai checkbox Remember Me.

**5. Potongan source code sebelum perbaikan**

login_screen.dart:

```dart
bool _rememberMe = false;

final success = await AppState.instance.login(
  _identifierController.text.trim(),
  _passwordController.text,
);
```

app_state.dart:

```dart
Future<bool> login(String identifier, String password) =>
    _authenticate(() => auth.repository.login(
      identifier.trim(), password
    ));
```

auth_repository.dart:

```dart
Future<Map<String, dynamic>> login(
  String identifier, String password
) => _authenticate('login', {
  'identifier': identifier,
  'password': password
});

Future<Map<String, dynamic>> _authenticate(
  String path,
  Map<String, dynamic> fields
) async {
  final body = await api.request(
    path, method: 'POST', data: fields
  );
  final data = Map<String, dynamic>.from(
    body['data'] as Map
  );
  await api.storage.save(data['token'] as String);
  return Map<String, dynamic>.from(data['user'] as Map);
}
```

token_storage.dart:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  static const _key = 'rusunawa_api_token';

  Future<String?> read() =>
      _storage.read(key: _key);

  Future<void> save(String token) =>
      _storage.write(key: _key, value: token);

  Future<void> clear() =>
      _storage.delete(key: _key);
}
```

Pada saat aplikasi dijalankan, AuthViewModel.restore() membaca token melalui repository.api.storage.read(), kemudian mengambil profil pengguna dari API. AppState menggunakan satu instance ApiService dan TokenStorage.

**6. Permintaan**

Tolong konfirmasi atau bantah hipotesis saya berdasarkan source code tersebut. Jelaskan root cause, berikan solusi kode untuk keempat file yang relevan, pertahankan arsitektur aplikasi, jangan menambah dependency yang tidak diperlukan, jangan menyimpan password, dan sertakan skenario pengujian setelah perbaikan.

## Perbandingan

| Aspek | A | B |
|---|---|---|
| Diagnosis | Umum | Unconditional token persistence |
| Solusi utama | SharedPreferences untuk email | RAM dan SecureStorage untuk token |
| Dependency | Menyarankan tambahan | Tidak perlu tambahan |
| Kesesuaian kode | Contoh generik | Empat file spesifik |
| Pengujian | Alur umum | 14 usulan test case, belum dieksekusi oleh AI |
| Keterbatasan | Meminta source code | Belum kompilasi; default berbeda dari implementasi |

## Refleksi

Eksperimen ini menunjukkan bahwa kualitas jawaban AI sangat dipengaruhi oleh kelengkapan konteks yang diberikan. Pada Prompt A, pertanyaan hanya menyebutkan fitur Ingat Saya yang tidak berfungsi. AI kemudian menawarkan solusi umum berupa penyimpanan email dan status checkbox dengan SharedPreferences. Jawaban tersebut berguna sebagai pengantar, termasuk peringatan agar tidak menyimpan password, tetapi belum langsung menyelesaikan masalah persistensi sesi pada aplikasi SIRUNAU. Jika diterapkan tanpa investigasi tambahan, solusi tersebut berpotensi menambah dependency dan perubahan yang tidak diperlukan.

Pada Prompt B, konteks teknologi, gejala, perilaku yang diharapkan, hasil reproduksi, hipotesis, dan potongan kode sebelum perbaikan disampaikan secara eksplisit. AI dapat menelusuri alur dari LoginScreen hingga TokenStorage serta mengidentifikasi penyimpanan token tanpa kondisi. Solusi menggunakan RAM dan SecureStorage sesuai dengan arsitektur aplikasi, tanpa perubahan backend. Jawaban tersebut juga mencakup empat belas rancangan pengujian dan membedakan rancangan dari hasil aktual.

Namun, jawaban yang lebih spesifik tetap harus diperiksa. Prompt B memilih nilai default rememberMe false, sedangkan implementasi proyek mempertahankan default true untuk kompatibilitas pemanggil lama dan registrasi, dengan nilai checkbox dikirim secara eksplisit saat login. Perbedaan ini perlu dipahami sebelum menyalin kode. Pengujian emulator pada implementasi proyek menunjukkan login tanpa centang, auto-login dengan centang, dan logout berjalan sesuai target. Tidak semua empat belas skenario usulan telah diuji.

Pelajaran utama adalah melakukan reproduksi, isolasi, dan pemeriksaan kode sebelum meminta bantuan AI. AI sebaiknya menjadi alat validasi hipotesis, bukan pengganti observasi. Eksperimen retrospektif ini membandingkan relevansi jawaban, bukan membuktikan bahwa Prompt B digunakan sebelum perbaikan.

## Lampiran A — Respons aktual AI

Fitur **Ingat Saya (Remember Me)** pada halaman login Flutter biasanya tidak berfungsi karena status checkbox, informasi akun, atau sesi autentikasi tidak disimpan secara permanen pada penyimpanan lokal perangkat.

Checkbox yang menggunakan `setState()` saja hanya menyimpan nilai sementara. Ketika aplikasi ditutup dan dibuka kembali, nilainya akan kembali ke kondisi awal.

## **1. Instal package SharedPreferences**

Gunakan `shared_preferences` untuk menyimpan status Ingat Saya dan email pengguna secara lokal.

Jalankan perintah berikut pada terminal project Flutter:

```
flutter pub add shared_preferences
```

Kemudian tambahkan import pada file halaman login, misalnya `login_page.dart`:

```
import 'package:shared_preferences/shared_preferences.dart';
```

## **2. Deklarasikan variabel**

Tambahkan variabel berikut di dalam class `State` halaman login:

```
final TextEditingController emailController =
    TextEditingController();

final TextEditingController passwordController =
    TextEditingController();

bool rememberMe = false;
```

## **3. Buat fungsi untuk menyimpan data login**

```
Future<void> saveLoginData() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool('remember_me', rememberMe);

  if (rememberMe) {
    await prefs.setString(
      'email',
      emailController.text.trim(),
    );
  } else {
    await prefs.remove('email');
  }
}
```

Fungsi tersebut akan menyimpan email apabila checkbox Ingat Saya dicentang dan menghapusnya apabila tidak dicentang.

**Catatan keamanan:** Jangan menyimpan password dalam `SharedPreferences` karena penyimpanannya tidak terenkripsi secara khusus untuk kredensial.

## **4. Buat fungsi untuk membaca data login**

Fungsi ini digunakan untuk mengambil kembali data yang telah disimpan ketika halaman login dibuka.

```
Future<void> loadLoginData() async {
  final prefs = await SharedPreferences.getInstance();

  if (!mounted) return;

  setState(() {
    rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe) {
      emailController.text =
          prefs.getString('email') ?? '';
    }
  });
}
```

## **5. Panggil fungsi pada initState()**

Pastikan fungsi `loadLoginData()` dipanggil ketika halaman login pertama kali dijalankan.

```
@override
void initState() {
  super.initState();
  loadLoginData();
}
```

Tanpa pemanggilan fungsi ini, data yang sudah tersimpan tidak akan ditampilkan kembali pada halaman login.

## **6. Perbaiki checkbox Ingat Saya**

```
CheckboxListTile(
  title: const Text('Ingat Saya'),
  value: rememberMe,
  controlAffinity: ListTileControlAffinity.leading,
  onChanged: (bool? value) {
    setState(() {
      rememberMe = value ?? false;
    });
  },
),
```

## **7. Panggil fungsi penyimpanan saat login berhasil**

Tambahkan `await saveLoginData()` pada fungsi autentikasi setelah login dinyatakan berhasil.

Contoh apabila menggunakan variabel `loginSuccess` sebagai indikator keberhasilan autentikasi:

```
if (loginSuccess) {
  await saveLoginData();

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage(),
    ),
  );
}
```

Sesuaikan `loginSuccess` dan `HomePage()` dengan kode project Anda.

## **8. Alur kerja fitur Ingat Saya**

[Diagram: label teks dari hasil salin] Aplikasi dibukaLoad data loginIngat Saya aktif?Tampilkan email tersimpanForm login kosongProses loginLogin berhasil?Checkbox dicentang?Tampilkan pesan kesalahanSimpan data loginHapus data tersimpanHalaman utamaYaTidakYaTidakYaTidak

## **9. Penyebab umum fitur Ingat Saya tidak berfungsi**

| Penyebab                                        | Solusi                                         |
| ----------------------------------------------- | ---------------------------------------------- |
| Checkbox hanya menggunakan `setState()`         | Gunakan `SharedPreferences`                    |
| Data tidak tersimpan                            | Panggil `saveLoginData()`                      |
| Data tidak muncul kembali                       | Panggil `loadLoginData()` pada `initState()`   |
| Nama key penyimpanan berbeda                    | Gunakan key yang konsisten                     |
| Proses penyimpanan belum selesai                | Gunakan `async` dan `await`                    |
| Controller diinisialisasi ulang dalam `build()` | Deklarasikan controller di dalam class `State` |
| Sesi autentikasi tidak dipertahankan            | Terapkan persistensi sesi autentikasi          |

## **10. Jika ingin pengguna tetap login secara otomatis**

Terdapat dua konsep implementasi fitur Ingat Saya yang perlu dibedakan:

- **Remember Credentials:** Mengingat email atau username pengguna.
- **Remember Session:** Mempertahankan sesi autentikasi sehingga pengguna tidak perlu login ulang ketika aplikasi dibuka.

Untuk mempertahankan sesi menggunakan REST API, gunakan `flutter_secure_storage` untuk menyimpan token autentikasi secara aman, kemudian lakukan pemeriksaan validitas token saat aplikasi dijalankan. Jika menggunakan Firebase Authentication, gunakan mekanisme persistensi sesi dan pemeriksaan status autentikasi Firebase.

```
flutter pub add flutter_secure_storage
```

Jangan menggunakan nilai boolean seperti `isLoggedIn = true` sebagai satu-satunya dasar autentikasi pengguna.

**Jika Anda mengirimkan kode berikut, saya dapat membantu mengidentifikasi letak kesalahan secara spesifik:**

- `login_page.dart`
- `auth_service.dart` atau `login_controller.dart` (jika ada)
- `main.dart`
- `splash_screen.dart` (jika ada)

Dengan demikian, perbaikan dapat disesuaikan dengan struktur project Flutter Anda, tanpa harus mengubah keseluruhan tampilan maupun arsitektur aplikasi. Contoh di atas masih bersifat umum karena kode sumber aplikasi Anda belum tersedia.

## Lampiran B — Respons aktual AI

## **1. Konfirmasi hipotesis**

**Hipotesis Anda benar.** Berdasarkan source code yang diberikan, fitur Ingat Saya (*Remember Me*) tidak berfungsi karena token autentikasi selalu disimpan secara persisten menggunakan `flutter_secure_storage`, tanpa mempertimbangkan nilai checkbox `_rememberMe`.

Permasalahan ini berada pada implementasi manajemen sesi di frontend Flutter, bukan pada mekanisme autentikasi Laravel Sanctum.

Checkbox sudah berfungsi secara visual, tetapi belum terintegrasi dengan alur autentikasi dan penyimpanan token.

## **2. Root Cause Analysis (RCA)**

Terdapat empat permasalahan yang saling berkaitan pada source code tersebut.

| File                   | Root cause                                                               |
| ---------------------- | ------------------------------------------------------------------------ |
| `login_screen.dart`    | Nilai `_rememberMe` tidak diteruskan saat memanggil fungsi `login()`.    |
| `app_state.dart`       | Fungsi `login()` tidak menerima parameter `rememberMe`.                  |
| `auth_repository.dart` | Token autentikasi selalu disimpan tanpa kondisi.                         |
| `token_storage.dart`   | Tidak terdapat mekanisme penyimpanan token sementara dalam memori (RAM). |

Baris kode yang secara langsung menyebabkan bug adalah:

```
await api.storage.save(data['token'] as String);
```

Setiap autentikasi berhasil, token disimpan melalui:

```
_storage.write(key: _key, value: token);
```

Penyimpanan tersebut bersifat persisten sehingga token tetap tersedia meskipun proses aplikasi telah dihentikan.

Ketika aplikasi dijalankan kembali, `AuthViewModel.restore()` menemukan token yang tersimpan, mengambil profil pengguna melalui API, kemudian memulihkan sesi login.

Akibatnya, mencentang atau tidak mencentang Ingat Saya menghasilkan perilaku autentikasi yang sama.

### **Alur autentikasi sebelum perbaikan**

[Diagram: label teks dari hasil salin] Pengguna mengisi form loginCheckbox Ingat SayaAppState.loginAuthRepository.loginLaravel REST APIToken autentikasi diterimaToken disimpan ke SecureStorageBerandaAplikasi dihentikanAplikasi dijalankan ulangAuthViewModel.restoreToken ditemukanDicentang atau tidak

Dengan demikian, akar masalahnya adalah **tidak adanya mekanisme pemilihan antara penyimpanan token persisten dan penyimpanan token sementara berdasarkan preferensi pengguna.**

## **3. Strategi perbaikan**

Solusi yang disarankan adalah menerapkan dua mekanisme penyimpanan token dalam class `TokenStorage` yang sudah tersedia.

| Kondisi                    | Lokasi penyimpanan       | Setelah proses aplikasi dihentikan |
| -------------------------- | ------------------------ | ---------------------------------- |
| Ingat Saya dicentang       | `flutter_secure_storage` | Token tetap tersedia               |
| Ingat Saya tidak dicentang | Memori/RAM               | Token hilang                       |
| Logout                     | Keduanya dihapus         | Sesi tidak dapat dipulihkan        |

Token sementara tetap diperlukan agar pengguna dapat mengakses endpoint API yang membutuhkan autentikasi selama aplikasi berjalan.

Solusi ini mempertahankan arsitektur yang sudah digunakan:

```
LoginScreen
    ↓
AppState
    ↓
AuthRepository
    ↓
ApiService
    ↓
TokenStorage
    ├── In-memory storage
    └── FlutterSecureStorage
```

Tidak diperlukan dependency tambahan, perubahan skema database MySQL, maupun pengiriman parameter `rememberMe` ke Laravel REST API. Password juga tidak perlu disimpan.

## **4. Implementasi perbaikan source code**

Perbaikan dilakukan pada empat file secara berurutan. Nama class, struktur repository, dan pola autentikasi yang sudah digunakan tetap dipertahankan.

### **A.&#x20;**`login_screen.dart`

Teruskan nilai checkbox `_rememberMe` sebagai named parameter ketika memanggil fungsi `login()`.

**Sebelum perbaikan:**

```
bool _rememberMe = false;

final success = await AppState.instance.login(
  _identifierController.text.trim(),
  _passwordController.text,
);
```

**Setelah perbaikan:**

```
bool _rememberMe = false;

final success = await AppState.instance.login(
  _identifierController.text.trim(),
  _passwordController.text,
  rememberMe: _rememberMe,
);
```

Pastikan implementasi checkbox tetap memperbarui state melalui `setState()`.

```
Checkbox(
  value: _rememberMe,
  onChanged: (bool? value) {
    setState(() {
      _rememberMe = value ?? false;
    });
  },
),
```

Apabila checkbox yang ada sudah berfungsi dengan benar, tidak perlu mengubah implementasi widget tersebut.

**Tujuan perbaikan:**

- Menghubungkan preferensi pengguna dengan proses autentikasi.
- Memastikan nilai `true` atau `false` diteruskan ke `AppState`.
- Mempertahankan nilai default Ingat Saya sebagai `false`.

### **B.&#x20;**`app_state.dart`

Tambahkan parameter `rememberMe` pada fungsi `login()` dan teruskan nilainya ke `AuthRepository`.

**Sebelum perbaikan:**

```
Future<bool> login(
  String identifier,
  String password,
) =>
    _authenticate(() => auth.repository.login(
      identifier.trim(),
      password,
    ));
```

**Setelah perbaikan:**

```
Future<bool> login(
  String identifier,
  String password, {
  bool rememberMe = false,
}) =>
    _authenticate(
      () => auth.repository.login(
        identifier.trim(),
        password,
        rememberMe: rememberMe,
      ),
    );
```

**Tujuan perbaikan:**

- Menerima preferensi Ingat Saya dari presentation layer.
- Meneruskan preferensi ke repository layer.
- Mempertahankan mekanisme `_authenticate()` yang sudah ada.
- Menjaga kompatibilitas pemanggilan fungsi `login()` yang hanya menggunakan dua parameter.

Parameter `rememberMe` menggunakan nilai default `false` agar sesi tidak disimpan secara persisten apabila preferensi tersebut tidak diberikan.

### **C.&#x20;**`auth_repository.dart`

Tambahkan parameter `rememberMe` pada fungsi `login()` dan `_authenticate()`. Selanjutnya, teruskan nilai tersebut ke fungsi `save()` pada `TokenStorage`.

**Kode setelah perbaikan:**

```
Future<Map<String, dynamic>> login(
  String identifier,
  String password, {
  bool rememberMe = false,
}) =>
    _authenticate(
      'login',
      {
        'identifier': identifier,
        'password': password,
      },
      rememberMe: rememberMe,
    );

Future<Map<String, dynamic>> _authenticate(
  String path,
  Map<String, dynamic> fields, {
  bool rememberMe = false,
}) async {
  final body = await api.request(
    path,
    method: 'POST',
    data: fields,
  );

  final data = Map<String, dynamic>.from(
    body['data'] as Map,
  );

  final token = data['token'] as String;

  final user = Map<String, dynamic>.from(
    data['user'] as Map,
  );

  await api.storage.save(
    token,
    rememberMe: rememberMe,
  );

  return user;
}
```

Perubahan utama terdapat pada:

```
await api.storage.save(
  token,
  rememberMe: rememberMe,
);
```

Repository tidak lagi menentukan bahwa seluruh token harus disimpan secara permanen. Keputusan penyimpanan diteruskan kepada `TokenStorage`.

Perhatikan bahwa data yang dikirimkan ke Laravel REST API tetap sama:

```
{
  'identifier': identifier,
  'password': password,
}
```

Parameter `rememberMe` hanya digunakan untuk kebijakan penyimpanan token di sisi Flutter, bukan untuk mengubah request autentikasi Laravel Sanctum.

**Catatan:** Apabila `_authenticate()` juga digunakan untuk fitur registrasi atau metode autentikasi lainnya, periksa pemanggilan tersebut agar kebijakan persistensi sesinya tetap sesuai dengan kebutuhan aplikasi.

### **D.&#x20;**`token_storage.dart`

File ini merupakan bagian paling penting dalam perbaikan karena bertanggung jawab mengelola token persisten dan token sementara.

**Kode lengkap setelah perbaikan:**

```
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  static const _key = 'rusunawa_api_token';

  // Token sementara yang hanya tersedia dalam memori.
  String? _memoryToken;

  Future<String?> read() async {
    // Prioritaskan token yang tersedia dalam memori.
    if (_memoryToken != null) {
      return _memoryToken;
    }

    // Jika tidak ada, baca token persisten.
    return _storage.read(key: _key);
  }

  Future<void> save(
    String token, {
    bool rememberMe = false,
  }) async {
    if (rememberMe) {
      // Simpan token secara persisten.
      await _storage.write(
        key: _key,
        value: token,
      );
    } else {
      // Hapus token persisten dari sesi sebelumnya.
      await _storage.delete(key: _key);
    }

    // Token tetap tersedia selama aplikasi berjalan.
    _memoryToken = token;
  }

  Future<void> clear() async {
    // Hapus token sementara.
    _memoryToken = null;

    // Hapus token persisten.
    await _storage.delete(key: _key);
  }
}
```

#### **Penjelasan setiap fungsi**

**1. Variabel&#x20;**`_memoryToken`

```
String? _memoryToken;
```

Variabel ini menyimpan token autentikasi dalam memori instance `TokenStorage`. Ketika proses aplikasi dihentikan, nilai tersebut tidak dipertahankan.

Karena `AppState` menggunakan satu instance `ApiService` dan `TokenStorage`, mekanisme ini dapat diterapkan tanpa menambahkan singleton baru.

**2. Fungsi&#x20;**`read()`

```
Future<String?> read() async {
  if (_memoryToken != null) {
    return _memoryToken;
  }

  return _storage.read(key: _key);
}
```

Fungsi ini menggunakan prioritas pembacaan token:

1. Membaca token dari memori.
2. Jika tidak tersedia, membaca token dari secure storage.
3. Jika keduanya tidak tersedia, menghasilkan `null`.

Dengan demikian, request API yang membutuhkan Bearer Token tetap dapat berjalan meskipun Ingat Saya tidak dicentang.

**3. Fungsi&#x20;**`save()`

Jika `rememberMe == true`, token disimpan ke secure storage dan memori.

Jika `rememberMe == false`, token hanya tersedia dalam memori dan token persisten sebelumnya dihapus.

Bagian berikut sangat penting:

```
await _storage.delete(key: _key);
```

Tanpa penghapusan tersebut, token persisten dari sesi sebelumnya berpotensi terbaca kembali ketika aplikasi dijalankan ulang.

**4. Fungsi&#x20;**`clear()`

```
Future<void> clear() async {
  _memoryToken = null;
  await _storage.delete(key: _key);
}
```

Fungsi ini memastikan logout membersihkan kedua lokasi penyimpanan token, baik token sementara maupun token persisten.

## **5. Alur autentikasi setelah perbaikan**

[Diagram: label teks dari hasil salin] Pengguna loginAppState.loginAuthRepository.loginLaravel Sanctum APIToken diterimaRemember Me?Simpan token ke RAM danSecure StorageHapus token persisten dansimpan ke RAMBerandaProses aplikasi dihentikanAplikasi dijalankan ulangAuthViewModel.restoreToken tersedia?BerandaHalaman LoginTrueFalseYa dan validTidak

Setelah perbaikan, keputusan untuk memulihkan sesi pengguna tidak lagi bergantung pada keberhasilan login sebelumnya saja, melainkan pada keberadaan dan validitas token autentikasi.

## **6. Apakah&#x20;**`AuthViewModel.restore()`**&#x20;perlu diubah?**

Berdasarkan deskripsi arsitektur yang diberikan, **tidak perlu**, selama fungsi tersebut sudah membaca token melalui:

```
final token = await repository.api.storage.read();
```

Saat aplikasi mengalami cold start, terdapat dua kemungkinan.

| Kondisi                    | `_memoryToken` | Secure storage | Hasil `read()` |
| -------------------------- | -------------- | -------------- | -------------- |
| Ingat Saya dicentang       | `null`         | Token tersedia | Token          |
| Ingat Saya tidak dicentang | `null`         | Kosong         | `null`         |
| Setelah logout             | `null`         | Kosong         | `null`         |

Pastikan fungsi `restore()` sudah menangani kondisi ketika token bernilai `null` dengan menetapkan status pengguna sebagai belum terautentikasi.

Selain itu, jika token tersedia tetapi API mengembalikan HTTP `401 Unauthorized` karena token kedaluwarsa atau telah dicabut, aplikasi harus membersihkan token dan mengarahkan pengguna ke halaman login.

Dengan demikian, perubahan dapat dilakukan tanpa merombak `AuthViewModel`.

## **7. Penanganan logout**

Untuk memenuhi persyaratan logout, pastikan implementasi logout yang sudah ada memanggil:

```
await api.storage.clear();
```

Dengan implementasi `TokenStorage` yang baru, pemanggilan tersebut otomatis menghapus token sementara dan token persisten.

Apabila repository belum menjamin pembersihan token ketika request logout gagal, pola berikut dapat digunakan sebagai referensi:

```
Future<void> logout() async {
  try {
    await api.request(
      'logout',
      method: 'POST',
    );
  } finally {
    await api.storage.clear();
  }
}
```

Sesuaikan nama endpoint dengan route Laravel yang sudah digunakan.

Pada level `AppState` atau `AuthViewModel`, pastikan state profil pengguna dan status autentikasi juga direset setelah logout, termasuk ketika request logout mengalami kegagalan jaringan.

Pada sisi Laravel Sanctum, endpoint logout idealnya mencabut token yang sedang digunakan:

```
$request->user()->currentAccessToken()->delete();
```

Penghapusan token lokal dan pencabutan token server merupakan dua mekanisme berbeda. Jika jaringan gagal, sesi lokal dapat dihapus, tetapi token di server belum tentu berhasil dicabut.

## **8. Skenario pengujian setelah perbaikan**

Metode pengujian yang disarankan adalah **black-box testing**, dilengkapi dengan regression testing terhadap fitur autentikasi yang sudah berjalan.

### **Tabel test case**

| ID    | Skenario pengujian                                                                    | Expected result                                                           |
| ----- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| TC-01 | Login dengan Ingat Saya dicentang                                                     | Login berhasil dan Beranda ditampilkan.                                   |
| TC-02 | Hentikan dan jalankan ulang aplikasi setelah TC-01                                    | Langsung masuk Beranda jika token masih valid.                            |
| TC-03 | Login tanpa mencentang Ingat Saya                                                     | Login berhasil dan Beranda ditampilkan.                                   |
| TC-04 | Hentikan dan jalankan ulang aplikasi setelah TC-03                                    | Halaman Login ditampilkan.                                                |
| TC-05 | Akses endpoint terproteksi tanpa mencentang Ingat Saya                                | Request API berhasil menggunakan token dalam memori.                      |
| TC-06 | Logout setelah login dengan Ingat Saya                                                | Token di memori dan secure storage terhapus.                              |
| TC-07 | Logout setelah login tanpa Ingat Saya                                                 | Token di memori terhapus dan halaman Login ditampilkan.                   |
| TC-08 | Jalankan ulang aplikasi setelah logout                                                | Halaman Login ditampilkan.                                                |
| TC-09 | Login dengan Ingat Saya, kemudian logout dan login tanpa Ingat Saya                   | Token tidak dipertahankan setelah aplikasi dihentikan.                    |
| TC-10 | Login menggunakan kredensial yang salah                                               | Login gagal dan tidak menyimpan token baru.                               |
| TC-11 | Token persisten tidak valid atau telah dicabut                                        | Sesi gagal dipulihkan dan halaman Login ditampilkan.                      |
| TC-12 | Aplikasi masuk background tanpa proses dihentikan, Ingat Saya tidak dicentang         | Sesi tetap aktif.                                                         |
| TC-13 | Logout ketika jaringan tidak tersedia                                                 | Sesi lokal terhapus; pencabutan token server belum terkonfirmasi.         |
| TC-14 | Token persisten lama tersedia, kemudian `save()` dipanggil dengan `rememberMe: false` | Token persisten lama terhapus dan token baru hanya tersedia dalam memori. |

Seluruh skenario tersebut merupakan rancangan pengujian dengan status **belum dieksekusi**, bukan hasil pengujian aktual.

### **Prosedur pengujian Android Emulator**

Untuk menguji persistensi sesi dengan benar, gunakan penghentian proses aplikasi (*force stop*), bukan hanya menekan tombol Home.

**Pengujian 1 — Ingat Saya dicentang**

1. Jalankan aplikasi SIRUNAU UBBG.
2. Masukkan identifier dan password yang valid.
3. Centang Ingat Saya.
4. Tekan tombol Login.
5. Pastikan Beranda ditampilkan.
6. Lakukan force stop aplikasi.
7. Jalankan kembali aplikasi.
8. Pastikan aplikasi langsung menampilkan Beranda.

**Pengujian 2 — Ingat Saya tidak dicentang**

1. Logout dari sesi sebelumnya.
2. Masukkan identifier dan password yang valid.
3. Jangan centang Ingat Saya.
4. Tekan tombol Login.
5. Pastikan Beranda ditampilkan.
6. Lakukan force stop aplikasi.
7. Jalankan kembali aplikasi.
8. Pastikan aplikasi menampilkan halaman Login.

**Pengujian 3 — Logout**

1. Login dengan Ingat Saya dicentang.
2. Masuk ke Beranda.
3. Tekan tombol Logout.
4. Pastikan halaman Login ditampilkan.
5. Hentikan proses aplikasi.
6. Jalankan kembali aplikasi.
7. Pastikan sesi sebelumnya tidak dipulihkan.

Force stop juga dapat dilakukan melalui Android Debug Bridge (ADB):

```
adb shell am force-stop <application_id>
```

Ganti `<application_id>` dengan application ID proyek Flutter SIRUNAU UBBG.

Jangan menggunakan Clear Data untuk menguji Remember Me karena tindakan tersebut juga menghapus data persisten aplikasi, sehingga dapat menghasilkan kesimpulan pengujian yang keliru.

### **Perbedaan lifecycle aplikasi**

| Tindakan                    | Ingat Saya aktif             | Ingat Saya tidak aktif                |
| --------------------------- | ---------------------------- | ------------------------------------- |
| Menekan tombol Home         | Tetap login                  | Tetap login selama proses masih hidup |
| Berpindah aplikasi          | Tetap login                  | Tetap login selama proses masih hidup |
| Hot reload                  | Tetap login                  | Umumnya tetap login                   |
| Hot restart                 | Sesi dapat dipulihkan        | Token dalam memori hilang             |
| Force stop dan buka kembali | Tetap login jika token valid | Login ulang                           |
| Logout                      | Login ulang                  | Login ulang                           |

Menutup tampilan aplikasi tidak selalu berarti proses aplikasi telah dihentikan oleh sistem operasi. Oleh karena itu, force stop merupakan metode yang lebih tepat untuk memvalidasi kasus bug ini.

## **9. Kriteria keberhasilan perbaikan**

- Nilai checkbox diteruskan dari `LoginScreen` ke `AppState`.
- `AppState` meneruskan parameter ke `AuthRepository`.
- `AuthRepository` meneruskan parameter ke `TokenStorage`.
- Token persisten hanya disimpan jika Ingat Saya dicentang.
- Token sementara tetap dapat digunakan untuk request API.
- Token persisten lama dihapus ketika Ingat Saya tidak dicentang.
- Sesi tanpa Ingat Saya tidak dipulihkan setelah cold start.
- Logout menghapus token dari kedua lokasi penyimpanan.
- Password tidak disimpan.
- Tidak ada dependency tambahan.
- Arsitektur aplikasi tetap dipertahankan.
- Seluruh skenario pengujian berhasil dijalankan.

## **10. Kesimpulan**

Bug fitur Remember Me pada aplikasi SIRUNAU UBBG dikategorikan sebagai **functional bug pada authentication session management**, khususnya pada kebijakan persistensi token autentikasi.

Hipotesis awal terkonfirmasi karena terdapat unconditional token persistence, yaitu penyimpanan token secara persisten tanpa mempertimbangkan preferensi pengguna.

Solusi yang diberikan menerapkan mekanisme *conditional token persistence* dengan memanfaatkan dua lokasi penyimpanan:

- **In-memory storage** untuk sesi sementara.
- **Flutter Secure Storage** untuk sesi persisten.

Pendekatan ini memiliki cakupan perubahan yang minimal, tidak membutuhkan dependency tambahan, tidak menyimpan password, tidak membutuhkan perubahan database, serta tetap kompatibel dengan arsitektur Flutter dan Laravel Sanctum yang digunakan.

**Batasan validasi:** Analisis dan implementasi ini didasarkan pada potongan source code yang diberikan. Saya belum memeriksa keseluruhan proyek, melakukan kompilasi, atau menjalankan pengujian pada Android Emulator. Keputusan menggunakan nilai default `rememberMe = false` merupakan kebijakan nonpersisten secara default yang saya pilih agar sesuai dengan perilaku checkbox awal. Pastikan juga pemanggil autentikasi lainnya dan implementasi logout yang sudah ada diperiksa sebelum perubahan diterapkan ke production.
