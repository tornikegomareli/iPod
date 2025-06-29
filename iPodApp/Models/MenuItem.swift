import Foundation

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String?
    let action: MenuAction
    let children: [MenuItem]?
    
    init(title: String, icon: String? = nil, action: MenuAction, children: [MenuItem]? = nil) {
        self.title = title
        self.icon = icon
        self.action = action
        self.children = children
    }
    
    static var mainMenuItems: [MenuItem] {
        [
            MenuItem(title: "Music", icon: "music.note", action: .navigate(musicMenuItems)),
            MenuItem(title: "Now Playing", icon: "play.circle", action: .showNowPlaying),
            MenuItem(title: "Settings", icon: "gear", action: .showSettings),
            MenuItem(title: "Shuffle Songs", icon: "shuffle", action: .custom { })
        ]
    }
    
    static var musicMenuItems: [MenuItem] {
        [
            MenuItem(title: "Playlists", icon: "music.note.list", action: .showLibraryPlaylists),
            MenuItem(title: "Artists", icon: "person", action: .showLibraryArtists),
            MenuItem(title: "Albums", icon: "square.stack", action: .showLibraryAlbums),
            MenuItem(title: "Songs", icon: "music.note", action: .showLibrarySongs),
            MenuItem(title: "Mock Songs", icon: "music.note", action: .navigate(songMenuItems))
        ]
    }
    
    static var playlistMenuItems: [MenuItem] {
        Playlist.mockPlaylists.map { playlist in
            MenuItem(
                title: playlist.name,
                icon: "music.note.list",
                action: .playPlaylist(playlist)
            )
        }
    }
    
    static var songMenuItems: [MenuItem] {
        Song.mockSongs.map { song in
            MenuItem(
                title: song.title,
                icon: nil,
                action: .playSong(song)
            )
        }
    }
}