import Foundation
import MediaPlayer
import Combine

class MusicLibraryService: ObservableObject {
    static let shared = MusicLibraryService()
    
    @Published var authorizationStatus: MPMediaLibraryAuthorizationStatus = .notDetermined
    @Published var songs: [Song] = []
    @Published var playlists: [Playlist] = []
    @Published var artists: [String: [Song]] = [:]
    @Published var albums: [String: [Song]] = [:]
    @Published var isLoading = false
    @Published var hasLoadedLibrary = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        authorizationStatus = MPMediaLibrary.authorizationStatus()
    }
    
    func requestAuthorization() async -> Bool {
        let status = await MPMediaLibrary.requestAuthorization()
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
        return status == .authorized
    }
    
    func loadMusicLibrary() async {
        /// Check if already loading or already loaded
        if isLoading || hasLoadedLibrary {
            print("Library already loaded or loading, skipping...")
            return
        }
        
        await MainActor.run {
            self.isLoading = true
        }
        
        if authorizationStatus != .authorized {
            let authorized = await requestAuthorization()
            print("Authorization result: \(authorized)")
            if !authorized {
                print("Music library authorization denied")
                await MainActor.run {
                    self.isLoading = false
                }
                return
            }
        }
        
        await MainActor.run {
            self.songs = []
            self.playlists = []
            self.artists = [:]
            self.albums = [:]
        }
        
        /// Fetch songs
        let songsQuery = MPMediaQuery.songs()
        print("Fetching songs from music library...")
        if let items = songsQuery.items {
            print("Found \(items.count) items in music library")
            let fetchedSongs = items.compactMap { convertToSong($0) }
            print("Converted \(fetchedSongs.count) songs")
            await MainActor.run {
                self.songs = fetchedSongs
                self.organizeSongsByArtist(fetchedSongs)
                self.organizeSongsByAlbum(fetchedSongs)
            }
        } else {
            print("No items found in music library query")
        }
        
        /// Fetch playlists
        let playlistsQuery = MPMediaQuery.playlists()
        if let collections = playlistsQuery.collections {
            let fetchedPlaylists = collections.compactMap { collection -> Playlist? in
                guard let playlist = collection as? MPMediaPlaylist,
                      let name = playlist.name,
                      !name.isEmpty else { return nil }
                
                let songs = playlist.items.compactMap { convertToSong($0) }
                return Playlist(name: name, songs: songs)
            }
            await MainActor.run {
                self.playlists = fetchedPlaylists
            }
        }
        
        await MainActor.run {
            self.isLoading = false
            self.hasLoadedLibrary = true
            print("Library loading complete")
        }
    }
    
    private func convertToSong(_ item: MPMediaItem) -> Song? {
        guard let title = item.title else { return nil }
        
        let artist = item.artist ?? "Unknown Artist"
        let album = item.albumTitle ?? "Unknown Album"
        let duration = item.playbackDuration
        let fileURL = item.assetURL
        let artworkData = item.artwork?.image(at: CGSize(width: 300, height: 300))?.pngData()
        let persistentID = item.persistentID
        
        return Song(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            fileURL: fileURL,
            artworkData: artworkData,
            persistentID: persistentID
        )
    }
    
    private func organizeSongsByArtist(_ songs: [Song]) {
        var artistDict: [String: [Song]] = [:]
        
        for song in songs {
            if artistDict[song.artist] != nil {
                artistDict[song.artist]?.append(song)
            } else {
                artistDict[song.artist] = [song]
            }
        }
        
        self.artists = artistDict
    }
    
    private func organizeSongsByAlbum(_ songs: [Song]) {
        var albumDict: [String: [Song]] = [:]
        
        for song in songs {
            if albumDict[song.album] != nil {
                albumDict[song.album]?.append(song)
            } else {
                albumDict[song.album] = [song]
            }
        }
        
        self.albums = albumDict
    }
    
    /// Search functionality
    func searchSongs(query: String) -> [Song] {
        guard !query.isEmpty else { return songs }
        
        let lowercasedQuery = query.lowercased()
        return songs.filter { song in
            song.title.lowercased().contains(lowercasedQuery) ||
            song.artist.lowercased().contains(lowercasedQuery) ||
            song.album.lowercased().contains(lowercasedQuery)
        }
    }
    
    /// Get songs for a specific artist
    func getSongsForArtist(_ artist: String) -> [Song] {
        return artists[artist] ?? []
    }
    
    /// Get songs for a specific album
    func getSongsForAlbum(_ album: String) -> [Song] {
        return albums[album] ?? []
    }
    
    /// Force reload the library
    func reloadLibrary() async {
        await MainActor.run {
            self.hasLoadedLibrary = false
        }
        await loadMusicLibrary()
    }
}
