import SwiftUI
import Combine
import MediaPlayer

class MusicPlayerViewModel: ObservableObject {
    @Published var playerState = PlayerState()
    
    private let systemMusicService = SystemMusicPlayerService.shared
    private let fallbackMusicService = MusicPlayerService.shared
    private var cancellables = Set<AnyCancellable>()
    private var useSystemPlayer = true
    
    init() {
        setupBindings()
        loadMockData()
    }
    
    private func setupBindings() {
        systemMusicService.$playerState
            .assign(to: &$playerState)
    }
    
    private func loadMockData() {
        playerState.playlist = Song.mockSongs
    }
    
    func togglePlayPause() {
        if useSystemPlayer && playerState.currentSong?.persistentID != nil {
            systemMusicService.togglePlayPause()
        } else {
            fallbackMusicService.togglePlayPause()
        }
    }
    
    func nextTrack() {
        if useSystemPlayer && playerState.currentSong?.persistentID != nil {
            systemMusicService.next()
        } else {
            fallbackMusicService.next()
        }
    }
    
    func previousTrack() {
        if useSystemPlayer && playerState.currentSong?.persistentID != nil {
            systemMusicService.previous()
        } else {
            fallbackMusicService.previous()
        }
    }
    
    func playSong(_ song: Song) {
        if let persistentID = song.persistentID {
            // Use system player for songs with persistent IDs
            let predicate = MPMediaPropertyPredicate(value: persistentID, forProperty: MPMediaItemPropertyPersistentID)
            let query = MPMediaQuery()
            query.addFilterPredicate(predicate)
            
            if let mediaItem = query.items?.first {
                let player = MPMusicPlayerController.applicationMusicPlayer
                let collection = MPMediaItemCollection(items: [mediaItem])
                player.setQueue(with: collection)
                player.play()
                
                // Update our state
                playerState.playlist = [song]
                playerState.currentIndex = 0
                playerState.currentSong = song
                playerState.isPlaying = true
                useSystemPlayer = true
            }
        } else {
            // Fall back to AVAudioPlayer for mock songs
            useSystemPlayer = false
            fallbackMusicService.loadSong(song)
            fallbackMusicService.play()
        }
    }
    
    func playPlaylist(_ playlist: Playlist) {
        let songsWithPersistentIDs = playlist.songs.filter { $0.persistentID != nil }
        
        if !songsWithPersistentIDs.isEmpty {
            // Use system player for real songs
            let persistentIDs = songsWithPersistentIDs.compactMap { $0.persistentID }
            systemMusicService.loadSongsWithPersistentIDs(songsWithPersistentIDs, persistentIDs: persistentIDs)
            systemMusicService.play()
            useSystemPlayer = true
        } else {
            // Fall back for mock playlists
            useSystemPlayer = false
            fallbackMusicService.loadPlaylist(playlist)
            fallbackMusicService.play()
        }
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