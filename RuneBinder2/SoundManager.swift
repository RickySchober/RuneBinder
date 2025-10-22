import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()

    private var soundEffects: [String: AVAudioPlayer] = [:]
    var duplicatePlayers: [AVAudioPlayer] = []
    private var musicPlayer: AVAudioPlayer?
    
    func preloadAll(from folder: String, fileExtension: String = "wav") {
           DispatchQueue.global(qos: .background).async { //use background queue to load at startup
               guard let soundPaths = Bundle.main.urls(forResourcesWithExtension: fileExtension, subdirectory: "") else { print("oops"); return}
               for url in soundPaths {
                   do {
                       let player = try AVAudioPlayer(contentsOf: url)
                       player.prepareToPlay()
                       DispatchQueue.main.async { //Force execution of variable assignment on main thread to avoid errors
                           self.soundEffects[url.lastPathComponent.replacingOccurrences(of: "."+fileExtension, with: "")] = player
                           //print("Added \(url.lastPathComponent.replacingOccurrences(of: "."+fileExtension, with: "")) to sounds")
                       }
                   } catch {
                       print("Error preloading sound: \(url.lastPathComponent) — \(error.localizedDescription)")
                   }
               }
               print("✅ Preloaded \(self.soundEffects.count) sounds")
           }
       }

    // MARK: - Sound Effects
    func playSoundEffect(named name: String) {
        DispatchQueue.main.async {
            if let player = self.soundEffects[name] {
                //each plyer has its own channel to play the same sound effect multiple times must create additional players
                if(!player.isPlaying){
                    player.currentTime = 0
                    player.play()
                }
                else{
                    let duplicatePlayer = try! AVAudioPlayer(contentsOf: player.url!)
                    self.duplicatePlayers.append(duplicatePlayer)
                    duplicatePlayer.prepareToPlay()
                    duplicatePlayer.play()
                }
            } else {
                print("⚠️ Sound \(name) not preloaded.")
            }
        }
        removeDuplicates()
    }
    func removeDuplicates(){
        duplicatePlayers.removeAll { !$0.isPlaying }
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
