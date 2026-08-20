import AVFoundation
import Foundation

final class SoundService {
    static let shared = SoundService()

    private var players: [AVAudioPlayer] = []

    private init() {}

    func play(_ fileName: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            print("SoundService: missing \(fileName)")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player.prepareToPlay()
            player.play()
            players.append(player)
            players.removeAll { !$0.isPlaying }
        } catch {
            print("SoundService: \(error.localizedDescription)")
        }
    }
}
