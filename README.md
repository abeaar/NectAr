
## 📂 Struktur Folder (Arsitektur MVVM)

Proyek ini menggunakan arsitektur **MVVM (Model-View-ViewModel)** yang dikombinasikan dengan prinsip *Clean Architecture* dan *Dependency Injection* untuk memisahkan logika UI dengan sistem AR.

Berikut adalah penjelasan tiap folder, tujuannya, beserta contoh file yang ada di dalamnya:

### 1. `Models/`
* **Tujuan**: Tempat penyimpanan struktur data murni (Data Structures), Enum, dan *State* yang tidak memiliki logika bisnis atau UI sama sekali.
* **Contoh File**: `ARTrackingState.swift` (Berisi enum `TrackingFailureReason`), `AppPhase.swift` (Berisi status fase aplikasi seperti `.story`, `.placement`).

### 2. `Services/`
* **Tujuan**: Tempat untuk *Heavy-lifting* dan Logika Bisnis. Semua yang berhubungan dengan interaksi ke *framework* Apple (seperti ARKit, Network) diletakkan di sini.
* **Contoh File**: `ARSessionManager.swift`. File ini mengurus konfigurasi kamera AR, menangkap *delegate* dari ARKit, dan memperbarui status pelacakan kamera. Kelas ini disembunyikan di balik protokol `ARSessionManagerProtocol` agar mudah di-test (Unit Testing).

### 3. `ViewModels/`
* **Tujuan**: Sebagai "Otak/Manajer" untuk UI. ViewModel bertugas menerjemahkan data teknis dari `Services` menjadi data  yang siap ditampilkan oleh UI, serta mengatur logika transisi status.
* **Contoh File**: `ARViewModel.swift`. File ini memanggil `ARSessionManager`, lalu menerjemahkan error ARKit (seperti `.excessiveMotion`) menjadi teks String yang bisa dibaca manusia (`"Slow down, moving too fast"`). ViewModel ini menggunakan *macro* `@Observable` agar SwiftUI bisa bereaksi otomatis.

### 4. `View/` (dan file Root seperti `ContentView.swift`)
* **Tujuan**: Murni untuk tampilan (*Presentation*). Di sinilah tata letak (ZStack, VStack), warna, dan animasi diatur. UI *dilarang keras* memiliki logika bisnis atau memanggil fungsi *hardware* secara langsung.
* **Contoh File**: `ARContainer.swift` (Membungkus ARView dari RealityKit agar bisa dipakai di SwiftUI), `ContentView.swift` (Layar utama yang merender komponen berdasarkan status di ViewModel).

### 5. `Repository/` *(Future)*
* **Tujuan**: Jika ke depannya aplikasi membutuhkan koneksi ke Database (CoreData/SwiftData) atau API Server (Backend), kodenya akan diletakkan di sini untuk memisahkan logika pengambilan data.

### 6. `Utilities/` & `Loaders/`
* **Tujuan**: Berisi fungsi-fungsi *helper* kecil, ekstensi (extension) Swift, atau *asset loader* 3D model (usdz) yang bisa dipakai di mana saja.

---

## 🔄 Contoh Kasus Data Flow (Alur Data)

Agar seluruh tim Developer sepemahaman, berikut adalah contoh **Alur Data (Data Flow)** ketika Pengguna (User) menggerakkan HP terlalu cepat saat memindai ruangan:

1. **[HARDWARE / ARKit]**
   Kamera iPhone mendeteksi pergerakan yang terlalu cepat. ARKit mengirimkan *event* perubahan status lewat fungsi `session(_:cameraDidChangeTrackingState:)`.
   👇
2. **[SERVICE] -> `ARSessionManager`**
   *Service* menangkap *event* tersebut. Ia mengubah variabel `trackingFailureReason` miliknya menjadi `.excessiveMotion`.
   👇
3. **[VIEWMODEL] -> `ARViewModel`**
   Karena *ViewModel* mengamati (observe) *Service*, ia sadar ada perubahan. *Computed property* `hintText` di dalam ViewModel secara otomatis menghitung ulang dan mengembalikan nilai *String* manusiawi: `"Slow down, moving too fast"`.
   👇
4. **[VIEW] -> `ContentView`**
   SwiftUI, berkat `@Observable`, menyadari bahwa `hintText` milik `ARViewModel` telah berubah. Layar kemudian **menggambar ulang (re-render)** komponen `Text(viewModel.hintText)`, sehingga tulisan di layar pengguna langsung berubah seketika.

### Kenapa Alur ini Penting?
Karena alur ini **Satu Arah (Unidirectional)**. 
`View` tidak pernah mengatur kamera. `View` hanya bereaksi terhadap `ViewModel`. Dan `ViewModel` hanya bertugas menerjemahkan data dari `Service`. Desain ini membuat aplikasi sangat mudah dicari *bug*-nya (mudah di-debug) dan tidak mudah rusak (scalable).
