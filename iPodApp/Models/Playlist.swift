import Foundation

struct Playlist: Identifiable {
    let id = UUID()
    let name: String
    var songs: [Song]
    let createdDate: Date
    
    init(name: String, songs: [Song] = [], createdDate: Date = Date()) {
        self.name = name
        self.songs = songs
        self.createdDate = createdDate
    }
    
    var duration: TimeInterval {
        songs.reduce(0) { $0 + $1.duration }
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours) hr \(minutes) min"
        } else {
            return "\(minutes) minutes"
        }
    }
    
    static var mockPlaylists: [Playlist] {
        [
            Playlist(name: "Favorites", songs: Song.mockSongs),
            Playlist(name: "Recently Added", songs: Array(Song.mockSongs.prefix(3))),
            Playlist(name: "Top 25 Most Played", songs: Song.mockSongs)
        ]
    }
}