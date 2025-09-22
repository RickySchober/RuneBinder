import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()

    private var soundEffects: [String: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?

    // MARK: - Sound Effects
    func playSoundEffect(named name: String, fileExtension: String = "wav") {
        if let url = Bundle.main.url(forResource: name, withExtension: fileExtension) {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.play()
                // Keep it alive until it finishes playing
                soundEffects[name] = player
            } catch {
                print("Error playing sound effect: \(error.localizedDescription)")
            }
        } else {
            print("Sound file \(name).\(fileExtension) not found.")
        }
    }

    // MARK: - Background Music
    func playBackgroundMusic(named name: String, fileExtension: String = "mp3", loop: Bool = true) {
        if let url = Bundle.main.url(forResource: name, withExtension: fileExtension) {
            do {
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                musicPlayer?.numberOfLoops = loop ? -1 : 0
                musicPlayer?.volume = 0.4
                musicPlayer?.prepareToPlay()
                musicPlayer?.play()
            } catch {
                print("Error playing background music: \(error.localizedDescription)")
            }
        } else {
            print("Music file \(name).\(fileExtension) not found.")
        }
    }

    func stopBackgroundMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }
}
