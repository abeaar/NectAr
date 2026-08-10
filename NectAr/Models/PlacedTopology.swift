import simd

/// The three placed markers' world-space transforms, captured once placement is
/// complete and handed from the preparation phase into the simulation phase.
struct PlacedTopology {
    let transforms: [DeviceKind: simd_float4x4]
}
