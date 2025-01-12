import AVFoundation

class SoundEffectPlayer {
    private var startSoundPlayer: AVAudioPlayer?
    private var stopSoundPlayer: AVAudioPlayer?

    init() {
        setupSounds()
    }

    private func setupSounds() {
        // Load start sound
        if let startSoundPath = Bundle.main.path(forResource: "start_record", ofType: "wav") {
            let startSoundUrl = URL(fileURLWithPath: startSoundPath)
            do {
                startSoundPlayer = try AVAudioPlayer(contentsOf: startSoundUrl)
                startSoundPlayer?.prepareToPlay()
            } catch {
                print("Error loading start sound: \(error)")
            }
        }

        // Load stop sound
        if let stopSoundPath = Bundle.main.path(forResource: "stop_record", ofType: "wav") {
            let stopSoundUrl = URL(fileURLWithPath: stopSoundPath)
            do {
                stopSoundPlayer = try AVAudioPlayer(contentsOf: stopSoundUrl)
                stopSoundPlayer?.prepareToPlay()
            } catch {
                print("Error loading stop sound: \(error)")
            }
        }
    }

    func playStartSound() {
        startSoundPlayer?.play()
    }

    func playStopSound() {
        stopSoundPlayer?.play()
    }
}
