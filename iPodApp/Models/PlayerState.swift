import Foundation

struct PlayerState {
    var currentSong: Song?
    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    var volume: Float = 0.7
    var repeatMode: RepeatMode = .off
    var shuffleEnabled: Bool = false
    var playlist: [Song] = []
    var currentIndex: Int = 0
    
    var hasNextSong: Bool {
        if repeatMode == .one || repeatMode == .all {
            return true
        }
        return currentIndex < playlist.count - 1
    }
    
    var hasPreviousSong: Bool {
        return currentIndex > 0 || repeatMode == .all
    }
    
    mutating func nextSong() {
        guard !playlist.isEmpty else { return }
        
        if repeatMode == .one {
            currentTime = 0
        } else if currentIndex < playlist.count - 1 {
            currentIndex += 1
            currentSong = playlist[currentIndex]
            currentTime = 0
        } else if repeatMode == .all {
            currentIndex = 0
            currentSong = playlist[currentIndex]
            currentTime = 0
        }
    }
    
    mutating func previousSong() {
        guard !playlist.isEmpty else { return }
        
        if currentTime > 3 {
            currentTime = 0
        } else if currentIndex > 0 {
            currentIndex -= 1
            currentSong = playlist[currentIndex]
            currentTime = 0
        } else if repeatMode == .all {
            currentIndex = playlist.count - 1
            currentSong = playlist[currentIndex]
            currentTime = 0
        }
    }
}