import SwiftUI
import Combine

class MusicPlayerViewModel: ObservableObject {
    @Published var playerState = PlayerState()
    
    private let musicService = MusicPlayerService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadMockData()
    }
    
    private func setupBindings() {
        musicService.$playerState
            .assign(to: &$playerState)
    }
    
    private func loadMockData() {
        playerState.playlist = Song.mockSongs
    }
    
    func togglePlayPause() {
        musicService.togglePlayPause()
    }
    
    func nextTrack() {
        musicService.next()
    }
    
    func previousTrack() {
        musicService.previous()
    }
    
    func playSong(_ song: Song) {
        musicService.loadSong(song)
        musicService.play()
    }
    
    func playPlaylist(_ playlist: Playlist) {
        musicService.loadPlaylist(playlist)
        musicService.play()
    }
    
    func toggleRepeatMode() {
        let modes: [RepeatMode] = [.off, .all, .one]
        if let currentIndex = modes.firstIndex(of: playerState.repeatMode) {
            playerState.repeatMode = modes[(currentIndex + 1) % modes.count]
        }
    }
    
    func toggleShuffle() {
        playerState.shuffleEnabled.toggle()
    }
}