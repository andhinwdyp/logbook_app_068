# Smart-Patrol Vision (Pengolahan Citra Digital)

Aplikasi *mobile* berbasis Flutter yang mengimplementasikan antarmuka kamera *real-time* dan Laboratorium Pengolahan Citra Digital (PCD) interaktif. Proyek ini bertujuan untuk menyimulasikan sistem pemantauan infrastruktur jalan (pendeteksi lubang dan retakan aspal).

## Fitur Utama (PCD Features)

Aplikasi ini menggunakan perpaduan pemrosesan GPU (untuk performa tinggi) dan pemrosesan CPU *Asynchronous* (Isolate) untuk operasi matematis yang berat.

* **Live Sensor Interface:** Akses kamera *real-time* tanpa distorsi rasio dengan *overlay bounding box* yang bergerak dinamis.
* **Operasi Titik (Point Operations):**
  * Manipulasi Kecerahan (*Safe Headroom Brightness*) dan Kontras (*Pivot Midtone*).
  * Penyesuaian Saturasi berbasis bobot *Luminance* mata manusia.
  * Filter Lensa Instan: Normal, Grayscale, Sepia, dan Invert (Citra Negatif).
* **Operasi Spasial & Statistik (Spatial Operations):**
  * **Lowpass Filter (Blur):** Menggunakan *Gaussian Blur* untuk mereduksi derau.
  * **Highpass Filter (Sharpen/Edge Detection):** Menggunakan matriks Kernel 3x3 untuk memperjelas tepi retakan jalan.
  * **Noise Injection:** Simulasi derau *Salt & Pepper* berbasis probabilitas acak.

## Panduan Instalasi (Installation Guide)

Proyek ini sangat bergantung pada perangkat keras kamera. **Sangat disarankan untuk menjalankan aplikasi ini pada perangkat Android fisik (Smartphone)**, bukan melalui Emulator bawaan Android Studio.

### Langkah-langkah:

1. **Clone Repositori**
   Buka terminal/CMD dan jalankan perintah berikut:
   ```bash
   git clone <masukkan_url_git_kamu>
   cd logbook_app_068
2. **Unduh Dependencies**
    Pastikan Anda sudah menginstal Flutter SDK. Unduh semua pustaka pendukung (seperti camera dan image):
    ```bash
    flutter pub get
3. **Jalankan Aplikasi**
    Sambungkan HP Android Anda ke komputer (pastikan mode USB Debugging di HP sudah aktif), lalu jalankan perintah:
    ```bash
    flutter run
