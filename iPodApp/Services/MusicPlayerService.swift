import AVFoundation
import Combine

class MusicPlayerService: ObservableObject {
    static let shared = MusicPlayerService()
    
    @Published var playerState = PlayerState()
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAudioSession()
        setupBindings()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupBindings() {
        $playerState
            .sink { [weak self] state in
                if state.isPlaying {
                    self?.startTimer()
                } else {
                    self?.stopTimer()
                }
            }
            .store(in: &cancellables)
    }
    
    func play() {
        guard let song = playerState.currentSong else { return }
        
        if let fileURL = song.fileURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                audioPlayer?.currentTime = playerState.currentTime
                audioPlayer?.play()
                playerState.isPlaying = true
            } catch {
                print("Failed to play audio: \(error)")
            }
        } else {
            playerState.isPlaying = true
            startTimer()
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        playerState.isPlaying = false
    }
    
    func togglePlayPause() {
        if playerState.isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func next() {
        playerState.nextSong()
        if playerState.isPlaying {
            play()
        }
    }
    
    func previous() {
        playerState.previousSong()
        if playerState.isPlaying {
            play()
        }
    }
    
    func seek(to time: TimeInterval) {
        playerState.currentTime = time
        audioPlayer?.currentTime = time
    }
    
    func setVolume(_ volume: Float) {
        playerState.volume = volume
        audioPlayer?.volume = volume
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateProgress() {
        if let player = audioPlayer {
            playerState.currentTime = player.currentTime
            
            if player.currentTime >= player.duration - 0.1 {
                handleSongEnd()
            }
        } else {
            playerState.currentTime += 0.1
            
            if let duration = playerState.currentSong?.duration,
               playerState.currentTime >= duration {
                handleSongEnd()
            }
        }
    }
    
    private func handleSongEnd() {
        if playerState.repeatMode == .one {
            seek(to: 0)
            play()
        } else if playerState.hasNextSong {
            next()
        } else {
            pause()
            seek(to: 0)
        }
    }
    
    func loadPlaylist(_ playlist: Playlist) {
        playerState.playlist = playlist.songs
        playerState.currentIndex = 0
        playerState.currentSong = playlist.songs.first
        playerState.currentTime = 0
    }
    
    func loadSong(_ song: Song) {
        playerState.playlist = [song]
        playerState.currentIndex = 0
        playerState.currentSong = song
        playerState.currentTime = 0
    }
}