import Foundation
import MediaPlayer
import Combine

class SystemMusicPlayerService: ObservableObject {
    static let shared = SystemMusicPlayerService()
    
    @Published var playerState = PlayerState()
    
    private let musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupNotifications()
        setupBindings()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playbackStateDidChange),
            name: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: musicPlayer
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nowPlayingItemDidChange),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: musicPlayer
        )
        
        musicPlayer.beginGeneratingPlaybackNotifications()
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
    
    @objc private func playbackStateDidChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.playerState.isPlaying = self.musicPlayer.playbackState == .playing
        }
    }
    
    @objc private func nowPlayingItemDidChange() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let currentItem = self.musicPlayer.nowPlayingItem {
                // Update current song info from the now playing item
                self.updateCurrentSong(from: currentItem)
            }
        }
    }
    
    private func updateCurrentSong(from item: MPMediaItem) {
        let song = Song(
            title: item.title ?? "Unknown",
            artist: item.artist ?? "Unknown Artist",
            album: item.albumTitle ?? "Unknown Album",
            duration: item.playbackDuration,
            fileURL: item.assetURL,
            artworkData: item.artwork?.image(at: CGSize(width: 300, height: 300))?.pngData()
        )
        playerState.currentSong = song
    }
    
    func play() {
        musicPlayer.play()
        playerState.isPlaying = true
    }
    
    func pause() {
        musicPlayer.pause()
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
        musicPlayer.skipToNextItem()
    }
    
    func previous() {
        musicPlayer.skipToPreviousItem()
    }
    
    func seek(to time: TimeInterval) {
        musicPlayer.currentPlaybackTime = time
        playerState.currentTime = time
    }
    
    func setVolume(_ volume: Float) {
        // MPMusicPlayerController doesn't support volume control
        // Volume is controlled by system volume
        playerState.volume = volume
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
        playerState.currentTime = musicPlayer.currentPlaybackTime
    }
    
    func loadPlaylist(_ playlist: Playlist) {
        let mediaItems = playlist.songs.compactMap { song -> MPMediaItem? in
            if let fileURL = song.fileURL {
                // Try to find the media item by its URL
                let predicate = MPMediaPropertyPredicate(value: fileURL.absoluteString, forProperty: MPMediaItemPropertyAssetURL)
                let query = MPMediaQuery()
                query.addFilterPredicate(predicate)
                return query.items?.first
            }
            return nil
        }
        
        if !mediaItems.isEmpty {
            let collection = MPMediaItemCollection(items: mediaItems)
            musicPlayer.setQueue(with: collection)
            playerState.playlist = playlist.songs
            playerState.currentIndex = 0
            playerState.currentSong = playlist.songs.first
            playerState.currentTime = 0
        }
    }
    
    func loadSong(_ song: Song) {
        if let fileURL = song.fileURL {
            let predicate = MPMediaPropertyPredicate(value: fileURL.absoluteString, forProperty: MPMediaItemPropertyAssetURL)
            let query = MPMediaQuery()
            query.addFilterPredicate(predicate)
            
            if let mediaItem = query.items?.first {
                let collection = MPMediaItemCollection(items: [mediaItem])
                musicPlayer.setQueue(with: collection)
                playerState.playlist = [song]
                playerState.currentIndex = 0
                playerState.currentSong = song
                playerState.currentTime = 0
            }
        }
    }
    
    /// Load songs by persistent IDs (more reliable than URLs)
    func loadSongsWithPersistentIDs(_ songs: [Song], persistentIDs: [MPMediaEntityPersistentID]) {
        let mediaItems = persistentIDs.compactMap { persistentID -> MPMediaItem? in
            let predicate = MPMediaPropertyPredicate(value: persistentID, forProperty: MPMediaItemPropertyPersistentID)
            let query = MPMediaQuery()
            query.addFilterPredicate(predicate)
            return query.items?.first
        }
        
        if !mediaItems.isEmpty {
            let collection = MPMediaItemCollection(items: mediaItems)
            musicPlayer.setQueue(with: collection)
            playerState.playlist = songs
            playerState.currentIndex = 0
            playerState.currentSong = songs.first
            playerState.currentTime = 0
        }
    }
    
    deinit {
        musicPlayer.endGeneratingPlaybackNotifications()
    }
}