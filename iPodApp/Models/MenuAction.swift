import Foundation

enum MenuAction {
    case navigate([MenuItem])
    case playSong(Song)
    case playPlaylist(Playlist)
    case showNowPlaying
    case showSettings
    case custom(() -> Void)
    case showLibrarySongs
    case showLibraryArtists
    case showLibraryAlbums
    case showLibraryPlaylists
    case showArtistSongs(String)
    case showAlbumSongs(String)
}