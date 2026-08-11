//
//  SimulationRouteResolver.swift
//  NectAr
//

import ARKit
import simd

enum SimulationRouteResolver {

    struct Leg {
        let destination: simd_float4x4
        let isObstructed: Bool
    }

    struct Route {
        let origin: simd_float4x4
        let legs: [Leg]
        let deadzoneHint: String?
    }

    enum Resolution {
        case blocked(String)
        case runnable(Route)
    }

    static func resolve(
        deviceA: simd_float4x4,
        router: simd_float4x4,
        deviceB: simd_float4x4,
        attributes: RouterAttributes,
        planes: [ARPlaneAnchor]
    ) -> Resolution {
        guard attributes.isOn else {
            return .blocked("The router is off and can't be reached")
        }

        let deviceAInRange = SimulationRangeChecker.isInRange(device: deviceA, router: router, range: attributes.range)
        let deviceBInRange = SimulationRangeChecker.isInRange(device: deviceB, router: router, range: attributes.range)

        switch (deviceAInRange, deviceBInRange) {
        case (false, false):
            return .blocked("Both devices are outside the router's range and can't reach it")

        case (true, true):
            let toRouter = isObstructed(deviceA, router, planes)
            let toDeviceB = isObstructed(router, deviceB, planes)
            return .runnable(Route(
                origin: deviceA,
                legs: [
                    Leg(destination: router, isObstructed: toRouter),
                    Leg(destination: deviceB, isObstructed: toDeviceB),
                    Leg(destination: router, isObstructed: toDeviceB),
                    Leg(destination: deviceA, isObstructed: toRouter)
                ],
                deadzoneHint: nil
            ))

        case (true, false):
            return roundTrip(between: deviceA, and: router, unreachable: .deviceB, planes: planes)

        case (false, true):
            return roundTrip(between: deviceB, and: router, unreachable: .deviceA, planes: planes)
        }
    }

 
    private static func roundTrip(
        between device: simd_float4x4,
        and router: simd_float4x4,
        unreachable: DeviceKind,
        planes: [ARPlaneAnchor]
    ) -> Resolution {
        let obstructed = isObstructed(device, router, planes)
        return .runnable(Route(
            origin: device,
            legs: [
                Leg(destination: router, isObstructed: obstructed),
                Leg(destination: device, isObstructed: obstructed)
            ],
            deadzoneHint: "\(unreachable.label) is outside the router's range and can't send or receive data"
        ))
    }

    private static func isObstructed(_ from: simd_float4x4, _ to: simd_float4x4, _ planes: [ARPlaneAnchor]) -> Bool {
        SimulationObstructionChecker.isObstructed(from: from, to: to, planes: planes)
    }
}
