# Data Flow

How a frame of camera input becomes a placed marker, and how a placed topology
becomes an animated packet — file by file, input to output.

## Overview

Three separate flows run in this app, and they do not share state beyond a single
`ARView` and one value type (``PlacedTopology``) handed from the first phase to the
second:

1. **Tracking hints** — a background loop that runs the whole time, turning ARKit's
   tracking state into on-screen text.
2. **Placement** — raycasts the screen center every frame to preview, and on demand to
   commit, a marker at a real surface.
3. **Simulation** — replays a fixed waypoint route with the packet, slowing legs that
   cross a real wall.

Each is traced below. Names in the diagrams are real types; follow the links in the
reference tables to their symbol docs.

## Flow 1 — Tracking hints

Runs continuously from ``ARViewModel/start()`` onward. Purely reactive: nothing polls,
ARKit pushes.

```
  ARKit (hardware)
        │
        │  session(_:cameraDidChangeTrackingState:)
        │  in: ARCamera  ─ camera.trackingState
        ▼
  ARSessionManager                                    Services/ARSessionManager.swift
        │  maps ARCamera.TrackingState ──▶ TrackingFailureReason?
        │  writes: trackingFailureReason
        │
        │  (@Observable — no explicit notify)
        ▼
  ARViewModel<Manager>                                ViewModels/ARViewModel.swift
        │  reads:  sessionManager.trackingFailureReason
        │  derives: hintText: String
        │           .excessiveMotion ──▶ "Slow down, moving too fast"
        ▼
  HintTextView                                        View/Components/HintTextView.swift
           renders the string
```

The indirection exists so the AR layer stays swappable: ``ARViewModel`` is generic over
``ARSessionManaging``, not tied to ``ARSessionManager``. See PRD goal G5.

| Function | Input | Output / effect |
|---|---|---|
| ``ARSessionManager/start()`` | — | Runs `ARWorldTrackingConfiguration` with `.horizontal` + `.vertical` plane detection |
| `ARSessionManager.session(_:cameraDidChangeTrackingState:)` | `ARSession`, `ARCamera` | Writes ``ARSessionManager/trackingFailureReason`` |
| ``ARViewModel/hintText`` | (reads tracking state) | `String` for the UI |

## Flow 2 — Placement

The `ARView` is created by ``ARViewModel`` but injected into the controller by the
`UIViewRepresentable` wrapper, because only the wrapper knows when UIKit has it.
Assigning it is what starts the per-frame preview loop.

```
  ARContainerView.makeUIView                    View/Components/ARContainer.swift
        │  controller.arView = arView
        ▼
  PlacementSceneController.arView.didSet        ViewModels/PlacementSceneController.swift
        │  subscribes to SceneEvents.Update
        │
        ├─────────────── every frame ───────────────────────────────┐
        │                                                           │
        ▼                                                           │
  updatePreview()                                                   │
        │  raycast(from: screen center, allowing: .estimatedPlane)   │
        │  in:  CGPoint (arView.bounds mid)                          │
        │  out: ARRaycastResult.worldTransform — or nothing          │
        │                                                           │
        │  no hit ──▶ freeze preview at last position ──────────────┤
        │                                                           │
        ▼                                                           │
  movePreviewEntity(_:to:)                                          │
        │  lerp translation + slerp rotation, factor 0.25            │
        │  (eases toward the target; a raw raycast is too noisy)     │
        └───────────────────────────────────────────────────────────┘

  ── on tap of the confirm button ─────────────────────────────────────

  PlacementActionButton                   View/Components/PlacementActionButton.swift
        │
        ├─ isComplete == false ──▶ confirmPlacement()
        │                               │  raycast screen center
        │                               ▼
        │                        DeviceEntityLoader.load(kind)     Loaders/
        │                               │  in:  DeviceKind
        │                               │  out: Entity + billboard label
        │                               ▼
        │                        AnchoredEntityPlacer.place(_:at:in:)   Services/
        │                               │  in:  Entity, simd_float4x4, Scene
        │                               │  out: AnchorEntity (identity transform)
        │                               ▼
        │                        placedTransforms[kind] = worldTransform
        │                        placedAnchors[kind]    = anchor
        │
        └─ isComplete == true ───▶ stopPreview()
                                   onComplete(PlacedTopology(transforms:))
                                        │
                                        ▼
                                  ContentView: currentPhase = .simulation(topology)
```

`isComplete` flips once all three ``DeviceKind`` cases have a transform — that is the
only gate between the two phases.

| Function | Input | Output / effect |
|---|---|---|
| ``PlacementSceneController/confirmPlacement()`` | (reads `selectedDeviceKind`, raycasts) | Adds one entry to ``PlacementSceneController/placedTransforms``; no-op if already placed or no surface hit |
| ``PlacementSceneController/reset()`` | — | Removes all anchors, clears transforms, restarts preview |
| ``PlacementSceneController/stopPreview()`` | — | Cancels the per-frame subscription; call before leaving the screen |
| ``DeviceEntityLoader/load(_:)`` | ``DeviceKind`` | `Entity` — Router from the `Router` bundle scaled `0.5`, devices as procedural discs |
| ``AnchoredEntityPlacer/place(_:at:in:)`` | `Entity`, `simd_float4x4`, `Scene` | `AnchorEntity` at world identity, preserving the entity's own scale |

> Note: Only ``DeviceKind/router`` gets a live ghost preview
> (`previewableKinds`). Device markers are tiny discs, so previewing them would show
> almost nothing.

## Flow 3 — Simulation

Obstruction is resolved **once**, up front — the room does not change shape mid-run, so
there is no reason to re-check per frame.

```
  SimulationView.onAppear                             View/SimulationView.swift
        │  startAnimating(topology:)
        ▼
  SimulationSceneController                 ViewModels/SimulationSceneController.swift
        │
        │  guard: all three transforms present, else bail
        │
        │  arView.session.currentFrame?.anchors ──▶ [ARPlaneAnchor]
        ▼
  WallObstructionChecker.isObstructed(from:to:planes:)      Services/
        │  in:  two simd_float4x4 + plane anchors
        │  ├─ keeps only .vertical planes
        │  ├─ transforms both points into wall-local space
        │  ├─ sign change in local Y ──▶ segment crosses the wall's plane
        │  └─ crossing point within planeExtent (+0.075 padding)?
        │  out: Bool — computed twice (A→Router, Router→B)
        ▼
  animationTask = Task { ... }
        │
        │  MailEntityLoader.load() ──▶ Entity (scale 0.3)
        │  AnchoredEntityPlacer.place(mail, at: deviceA, ...)
        │
        │  waypoints  = [router, deviceB, router, deviceA]
        │  obstructed = [ A→R  ,   R→B  ,   R→B ,   A→R  ]
        │
        └─▶ while !Task.isCancelled:
                for each (waypoint, isObstructed):
                    legDuration = isObstructed ? 3s × 2 : 3s
                    currentLegHint = isObstructed
                        ? "Passing through wall — signal slowed" : nil
                    mail.move(to:relativeTo: nil, duration: legDuration)
                    await Task.sleep(legDuration)
                              │
                              ▼
                    HintTextView renders currentLegHint
```

Two details in the loop are deliberate. The packet's rotation is pinned to its initial
value rather than each waypoint's surface rotation, so it does not spin as it travels;
and its scale is re-applied on every leg, because `Transform(matrix:)` would otherwise
overwrite the `0.3` set at load time.

`relativeTo: nil` means world space — which only works because
``AnchoredEntityPlacer/place(_:at:in:)`` parents everything under an identity anchor.
Anchoring at the target transform instead would silently make every later move relative
to a tilted surface.

| Function | Input | Output / effect |
|---|---|---|
| ``SimulationSceneController/startAnimating(topology:)`` | ``PlacedTopology`` | Starts the looping animation; cancels any run already in progress |
| ``SimulationSceneController/stopAnimating()`` | — | Cancels the task, clears `currentLegHint` |
| ``WallObstructionChecker/isObstructed(from:to:planes:)`` | 2 × `simd_float4x4`, `[ARPlaneAnchor]` | `Bool` — approximate, uses flat plane anchors, not a LiDAR mesh |

## Phase transition

``AppPhase`` is the whole router. There is no `NavigationStack`; `ContentView` switches
on the enum and the associated value carries the payload forward.

```
  ContentView                                          View/ContentView.swift
        │
        ├─ .preparation                 ──▶ PreparationView ──▶ ARCameraView
        │       onComplete(PlacedTopology)
        │              │
        │              ▼
        └─ .simulation(PlacedTopology)  ──▶ SimulationView
                onExit()  ──▶ back to .preparation
```

``ARViewModel`` and ``PlacementSceneController`` are owned by `ContentView` as `@State`
and survive the transition; ``SimulationSceneController`` is created fresh by
`SimulationView` each time it appears.

## Topics

### Referenced types

- ``AppPhase``
- ``PlacedTopology``
- ``DeviceKind``
- ``TrackingFailureReason``
