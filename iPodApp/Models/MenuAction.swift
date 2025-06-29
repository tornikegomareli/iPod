import Foundation

enum MenuAction {
    case navigate([MenuItem])
    case playSong(Song)
    case playPlaylist(Playlist)
    case showNowPlaying
    case showSettings
    case custom(() -> Void)
}