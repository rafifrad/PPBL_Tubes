# Penjelasan Aplikasi Kelola Kebutuhan Kost

## 📱 Ringkasan Aplikasi

Aplikasi ini adalah aplikasi Flutter untuk mengelola kebutuhan kost, dengan 3 fitur utama:
1. **CRUD Persediaan Makanan** - Kelola stok makanan
2. **CRUD Peralatan Kamar** - Kelola peralatan di kamar
3. **CRUD Laundry** - Kelola laundry

## ✅ Ketentuan yang Dipenuhi

### 1. SQLite Database (3 Operasi + 3 Tabel)
- ✅ **3 Tabel**: `persediaan_makanan`, `peralatan_kamar`, `laundry`
- ✅ **Operasi SQLite**: INSERT, UPDATE, DELETE (3 operasi utama)
- ✅ File: `lib/database/database_helper.dart`

### 2. SharedPreferences
- ✅ Menyimpan nama pengguna
- ✅ Menyimpan pengaturan aplikasi
- ✅ File: `lib/services/preferences_service.dart`

### 3. Navigation
- ✅ **Navigation Drawer** - Menu samping untuk navigasi
- ✅ **Bottom Navigation Bar** - Menu bawah untuk navigasi cepat
- ✅ File: `lib/main.dart`

## 📁 Struktur File

```
lib/
├── main.dart                          # Entry point + Navigation
├── models/
│   ├── food.dart                      # Model Persediaan Makanan
│   ├── equipment.dart                 # Model Peralatan Kamar
│   └── laundry.dart                   # Model Laundry
├── database/
│   └── database_helper.dart           # SQLite Database Helper
├── services/
│   └── preferences_service.dart       # SharedPreferences Service
└── screens/
    ├── home_screen.dart               # Halaman Beranda
    ├── food_screen.dart               # CRUD Persediaan Makanan
    ├── equipment_screen.dart          # CRUD Peralatan Kamar
    └── laundry_screen.dart            # CRUD Laundry
```

## 🔧 Fitur CRUD

### 1. Persediaan Makanan
- **Field**: Nama Barang, Jumlah, Tanggal Beli
- **Fitur**: Tambah, Lihat, Edit, Hapus
- **Warna**: Hijau (Green)

### 2. Peralatan Kamar
- **Field**: Nama Barang, Kondisi (Baik/Rusak Ringan/Rusak Berat/Perlu Perbaikan), Lokasi
- **Fitur**: Tambah, Lihat, Edit, Hapus
- **Warna**: Biru (Blue)

### 3. Laundry
- **Field**: Jenis Pakaian, Jumlah, Status (Pending/Sedang Dicuci/Selesai)
- **Fitur**: Tambah, Lihat, Edit, Hapus
- **Warna**: Ungu (Purple)

## 🚀 Cara Menjalankan

1. Install dependencies:
```bash
flutter pub get
```

2. Jalankan aplikasi:
```bash
flutter run
```

## 📝 Penjelasan Singkat Kode

### Database Helper (`database_helper.dart`)
- Mengelola koneksi ke database SQLite
- Membuat 3 tabel saat pertama kali aplikasi dijalankan
- Menyediakan fungsi CRUD untuk setiap tabel

### Preferences Service (`preferences_service.dart`)
- Menyimpan data sederhana seperti nama pengguna
- Data tersimpan secara lokal di perangkat

### Navigation (`main.dart`)
- Menggunakan **Drawer** (menu samping) dan **Bottom Navigation Bar**
- Setiap halaman dapat diakses dari kedua menu

### Screens
- Setiap screen memiliki fungsi lengkap untuk CRUD
- Menggunakan dialog untuk form tambah/edit
- Validasi input sebelum menyimpan data

## 🎨 UI/UX
- Material Design 3
- Color-coded untuk setiap fitur
- Empty state yang informatif
- Loading indicator saat memuat data
- Snackbar untuk feedback aksi

## 📦 Dependencies
- `sqflite` - SQLite database
- `path` - Path utilities
- `shared_preferences` - Local storage

---

**Catatan**: Aplikasi ini memenuhi semua ketentuan tugas besar dengan implementasi yang clean dan mudah dipahami.

