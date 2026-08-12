# NectAr

Aplikasi iOS AR (ARKit + RealityKit + SwiftUI) yang membuat topologi jaringan
terlihat di ruangan pengguna. Pengguna menempatkan tiga marker — **Device A**,
**Router**, dan **Device B** — di permukaan nyata, lalu menonton "paket surat"
berjalan A → Router → B → Router → A untuk menunjukkan bahwa trafik itu dirutekan
(bukan langsung) dan tiap hop memakan waktu nyata. Detail produk lengkap ada di
[NectAr/PRD.md](NectAr/PRD.md).

## Cara jalankan

Build & run lewat Xcode (`NectAr.xcodeproj`, scheme `NectAr`), atau:

```bash
xcodebuild -project NectAr.xcodeproj -scheme NectAr -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Fitur AR (kamera passthrough, plane detection, raycasting) butuh perangkat fisik —
simulator bisa build tapi tracking/placement tidak akan berfungsi. Tidak ada test
target di project ini.

## 📂 Struktur project

- **`App/`** — entry point (`NectArApp.swift`).
- **`Models/`** — data murni tanpa dependensi UI: `AppPhase`, `DeviceKind`,
  `PlacedTopology`, `TrackingFailureReason`. (`Story`/`StoryCatalog` juga ada di sini,
  tapi belum dipakai oleh View manapun.)
- **`Services/`** — integrasi ARKit dan logika inti: `ARSessionManager` (+ protokol
  `ARSessionManaging`), `AnchoredEntityPlacer`, `PlacementPreviewStyler`,
  `WallObstructionChecker`.
- **`ViewModels/`** — state UI reaktif (`@Observable`): `ARViewModel`,
  `PlacementSceneController` (fase preparation), `SimulationSceneController` (fase
  simulation).
- **`Loaders/`** — `DeviceEntityLoader`, membangun entity 3D + label mengambang.
- **`View/`** — lapisan presentasi SwiftUI: `ContentView`, `PreparationView`,
  `SimulationView`, `ARCameraView`, dan `View/Components/*`.

Tidak ada database atau persistence layer — sesuai PRD, topologi yang ditempatkan
tidak disimpan lintas sesi.

Paket lokal `Router` (`./Router`) berisi aset 3D (`Router.usdz`, `mail.usda`/`.usdz`)
dan dipakai lewat `import Router`. Paket `Bee`, `Mail`, `Mail_3d`, `Router_3d` ada di
root repo tapi belum di-import oleh target `NectAr` — anggap eksperimen/belum
terhubung, bukan bagian aktif dari arsitektur.

## 🔄 Alur data

Alur searah (unidirectional), dari sensor ARKit sampai render SwiftUI:

1. **ARKit** — delegate callback melaporkan perubahan tracking state.
2. **`ARSessionManager`** — menangkap callback itu, memperbarui
   `trackingFailureReason`.
3. **`ARViewModel`** — menerjemahkan state itu jadi `hintText` siap tampil.
4. **View** — SwiftUI re-render otomatis lewat `@Observable`.

Untuk penempatan marker dan animasi paket surat, alurnya:

```
raycast layar tengah → PlacementSceneController.confirmPlacement()
  → DeviceEntityLoader.load(kind) → AnchoredEntityPlacer.place()
  → placedTransforms terkumpul → PlacedTopology → ContentView pindah ke fase simulation
  → SimulationSceneController menganimasikan mail entity mengelilingi topologi
```

`AppPhase` (`.preparation` / `.simulation(PlacedTopology)`) berperan sebagai router
aplikasi — tidak ada `NavigationStack`.

Lihat [CLAUDE.md](CLAUDE.md) untuk detail arsitektur dan keputusan desain.
