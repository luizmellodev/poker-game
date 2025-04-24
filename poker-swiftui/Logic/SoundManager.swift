import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [URL: AVAudioPlayer] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var isSoundEnabled = true
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func playSound(named filename: String) {
        guard isSoundEnabled else { return }
        
        if let path = Bundle.main.path(forResource: filename, ofType: "wav") {
            let url = URL(fileURLWithPath: path)
            
            if let player = audioPlayers[url] {
                player.currentTime = 0
                player.play()
            } else {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    audioPlayers[url] = player
                    player.prepareToPlay()
                    player.volume = 0.3
                    player.play()
                } catch {
                    print("Failed to play sound: \(error)")
                }
            }
        } else {
            print("Sound file not found: \(filename).wav")
        }
    }
    
    func playCardFlip() {
        playSound(named: "card_flip")
    }
    
    func playCall() {
        playSound(named: "call")
    }
    
    func playBet() {
        playSound(named: "bet")
    }
    
    func playCheck() {
        playSound(named: "check")
    }
    
    func playFold() {
        playSound(named: "fold")
    }
    
    func playWin() {
        playSound(named: "win")
    }
    
    func playLose() {
        playSound(named: "lose")
    }
    
    func playGameStart() {
        playSound(named: "chip_stack")
    }
    
    func playBackgroundMusic() {
        guard isSoundEnabled else { return }
        
        if let path = Bundle.main.path(forResource: "background_music", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
                backgroundMusicPlayer?.volume = 0.1
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()
            } catch {
                print("Failed to play background music: \(error)")
            }
        } else {
            print("Background music file not found")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
        if !isSoundEnabled {
            stopBackgroundMusic()
        } else {
            playBackgroundMusic()
        }
    }
    
    func playMenuSound() {
        playSound(named: "click")
    }
    
    func playTurnChange() {
        playSound(named: "turn_change")
    }
}
