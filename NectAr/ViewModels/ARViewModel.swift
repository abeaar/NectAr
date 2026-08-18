//
//  NectAr
//
//  Created by abr on 01/08/26.
//
import ARKit
import RealityKit
import Combine
import Foundation

@Observable
final class ARViewModel<Manager: ARSessionManaging> {
    private static var hintHoldDuration: TimeInterval { 2 }

    private let sessionManager: Manager
    let arView: ARView

    /// Held for at least `hintHoldDuration` once shown, so rapid tracking-state
    /// churn doesn't flicker unreadable text, see `advanceHintNow()`.
    private(set) var hintText: String?
    private var hintHoldTask: Task<Void, Never>?
    private var updateSubscription: Cancellable?

    init(sessionManager: Manager) {
        self.sessionManager = sessionManager
        self.arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        self.arView.session = sessionManager.session
        updateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] _ in
            self?.refreshHintText()
        }
    }

    /// Nil while tracking is nominal, real feedback only surfaces for an
    /// actual session error or tracking failure.
    private var rawHintText: String? {
        if let sessionError = sessionManager.sessionError {
            return sessionError
        }
        switch sessionManager.trackingFailureReason {
        case .none:
            // Debug only, uncomment to surface: return "Move your device to find a surface"
            return nil
        case .initializing:
            return "Hold still, starting up..."
        case .excessiveMotion:
            return "Slow down, moving too fast"
        case .insufficientFeatures:
            return "Point at a surface with more detail or light"
        case .relocalizing:
            return "Recovering tracking, move slowly"
        }
    }

    private func refreshHintText() {
        guard hintHoldTask == nil else { return }
        applyHintText(rawHintText)
    }

    private func applyHintText(_ text: String?) {
        hintText = text
        guard text != nil else { return }
        hintHoldTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(Self.hintHoldDuration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.hintHoldTask = nil
            self?.refreshHintText()
        }
    }

    /// Cuts the current hint's hold short, called when the card is tapped
    /// instead of waiting out the default duration.
    func advanceHintNow() {
        hintHoldTask?.cancel()
        hintHoldTask = nil
        refreshHintText()
    }

    func start() {
        sessionManager.start()
    }

    func pause() {
        sessionManager.pause()
        hintHoldTask?.cancel()
        hintHoldTask = nil
        hintText = nil
    }
}

extension ARViewModel where Manager == ARSessionManager {
    convenience init() {
        self.init(sessionManager: ARSessionManager())
    }
}
