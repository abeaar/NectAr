# NectAr Architecture

@Metadata {
    @TechnologyRoot
}

An iOS AR app (ARKit + RealityKit + SwiftUI) that makes network topology visible in
the user's room: place Device A, a Router, and Device B, then watch a mail packet
travel A → Router → B → Router → A.

## Overview

See [PRD.md](../PRD.md) for full product intent, goals, and non-goals. This page
documents the architecture for developers picking up the project — read it alongside
the symbol docs on each type below, which cover the "why" behind non-obvious
decisions.

The app is MVVM with the AR layer isolated behind ``ARSessionManaging`` (PRD goal G5).
Data flows one-directionally: ARKit delegate callbacks → service state → view
model/controller derived properties → SwiftUI re-render.

``AppPhase`` is the app's only router — there's no navigation stack. `ContentView`
switches on it directly, and ``PlacedTopology`` is the payload carried from the
preparation phase into the simulation phase.

## Topics

### Essentials

- <doc:DataFlow>

### App flow

- ``AppPhase``
- ``PlacedTopology``
- ``DeviceKind``

### AR session

- ``ARSessionManaging``
- ``ARSessionManager``
- ``ARViewModel``
- ``TrackingFailureReason``

### Placement phase

- ``PlacementSceneController``
- ``AnchoredEntityPlacer``
- ``DeviceEntityLoader``

### Simulation phase

- ``SimulationSceneController``
- ``WallObstructionChecker``
