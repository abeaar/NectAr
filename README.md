# NectAr

## 📂 Arsitektur Proyek

Proyek ini mengadopsi arsitektur **MVVM (Model-View-ViewModel)** yang dipadukan dengan prinsip *Clean Architecture* dan *Dependency Injection* untuk memisahkan logika antarmuka (UI) dengan sistem pengenalan ruang (AR).

### Struktur Direktori

- **`App/`**: Titik masuk utama aplikasi (Entry point).
  - *File*: `NectArApp.swift`.
- **`Models/`**: Definisi struktur data, entitas murni, enum, dan *state* tanpa dependensi UI.
  - *File*: `AppPhase.swift`, `Story.swift`, `TrackingFailureReason.swift`.
- **`Services/`**: Layer integrasi *framework* (misal: ARKit) dan *heavy-lifting* logika inti.
  - *File*: `ARSessionManager.swift` (implementasi), `ARSessionManaging.swift` (protokol).
- **`ViewModels/`**: Pengelola *state* UI. Menerjemahkan data dari *Services* menjadi format presentasi yang reaktif (`@Observable`).
  - *File*: `ARViewModel.swift`.
- **`View/`**: Lapisan presentasi berbasis SwiftUI. Menangani *layout*, warna, dan komponen visual murni.
  - *File*: `ContentView.swift`, `ARContainer.swift`, `PreparationView.swift`, `StoryView.swift`, `ARCameraView.swift`.
- **`Resources/`**: Aset statis aplikasi.
  - *File*: `Assets.xcassets`.
- **`Repository/`**: *(Future)* Layer akses data (CoreData/SwiftData atau eksternal API).
- **`Loaders/` & `Utilities/`**: Fungsi utilitas dan pemuat model 3D (usdz).

---

## 🔄 Alur Data (Data Flow)

Aplikasi mengimplementasikan alur data **searah (unidirectional)** yang reaktif:

1. **[Hardware] Sensor ARKit**: Kamera mendeteksi perubahan (contoh: pergerakan terlalu cepat).
2. **[Service] `ARSessionManager`**: Menangkap *event* delegasi ARKit dan memperbarui *state* internal (misal: `trackingFailureReason = .excessiveMotion`).
3. **[ViewModel] `ARViewModel`**: Bereaksi terhadap perubahan di *Service*, lalu memprosesnya menjadi properti siap pakai untuk UI (misal: `hintText = "Slow down, moving too fast"`).
4. **[View] `ContentView`**: SwiftUI membaca perubahan pada *ViewModel* (berkat `@Observable`) dan melakukan *render* ulang (re-render) pada komponen teks secara otomatis.

Desain pemisahan lapisan (*Separation of Concerns*) ini membuat aplikasi memiliki *testability* tinggi dan lebih mudah dipelihara (*maintainable*).
