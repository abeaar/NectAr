import Combine
import Foundation

@MainActor
final class SoundViewModel: ObservableObject {
    func play(_ fileName: String) {
        SoundService.shared.play(fileName)
    }
}
