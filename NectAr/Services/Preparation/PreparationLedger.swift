//
//  PreparationLedger.swift
//  NectAr
//

import RealityKit
import simd

struct PreparationLedger {
    private struct Entry {
        let transform: simd_float4x4
        let anchor: AnchorEntity
    }

    private var entries: [DeviceKind: Entry] = [:]
    private var order: [DeviceKind] = []

    var kinds: Set<DeviceKind> { Set(entries.keys) }
    var transforms: [DeviceKind: simd_float4x4] { entries.mapValues(\.transform) }
    var isEmpty: Bool { entries.isEmpty }

    mutating func record(_ kind: DeviceKind, transform: simd_float4x4, anchor: AnchorEntity) {
        entries[kind] = Entry(transform: transform, anchor: anchor)
        order.append(kind)
    }

    mutating func removeLast() -> (kind: DeviceKind, anchor: AnchorEntity)? {
        guard let kind = order.popLast(), let entry = entries.removeValue(forKey: kind) else { return nil }
        return (kind, entry.anchor)
    }

    mutating func removeAll() -> [AnchorEntity] {
        defer {
            entries.removeAll()
            order.removeAll()
        }
        return entries.values.map(\.anchor)
    }
}
