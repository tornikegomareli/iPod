import Foundation
import MediaPlayer

struct Song: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artist: String
    let album: String
    let duration: TimeInterval
    let fileURL: URL?
    let artworkData: Data?
    let persistentID: MPMediaEntityPersistentID?
    
    init(title: String, artist: String, album: String, duration: TimeInterval, fileURL: URL? = nil, artworkData: Data? = nil, persistentID: MPMediaEntityPersistentID? = nil) {
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.fileURL = fileURL
        self.artworkData = artworkData
        self.persistentID = persistentID
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    static var mockSongs: [Song] {
        [
            Song(title: "Hey Jude", artist: "The Beatles", album: "The Beatles Again", duration: 431),
            Song(title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera", duration: 354),
            Song(title: "Hotel California", artist: "Eagles", album: "Hotel California", duration: 391),
            Song(title: "Stairway to Heaven", artist: "Led Zeppelin", album: "Led Zeppelin IV", duration: 482),
            Song(title: "Imagine", artist: "John Lennon", album: "Imagine", duration: 183)
        ]
    }
}