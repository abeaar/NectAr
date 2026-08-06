import simd

struct PlacedTopology {
    let transforms: [DeviceKind: simd_float4x4]
}
