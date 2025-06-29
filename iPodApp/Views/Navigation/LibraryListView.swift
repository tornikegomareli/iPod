import SwiftUI

struct LibraryListView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @Binding var currentMenuItems: [MenuItem]
    @Binding var selectedIndex: Int
    @Binding var navigationStack: [(title: String, items: [MenuItem])]
    let libraryType: LibraryType
    let artistOrAlbumName: String?
    
    enum LibraryType {
        case songs
        case artists
        case albums
        case playlists
        case artistSongs
        case albumSongs
    }
    
    init(currentMenuItems: Binding<[MenuItem]>, 
         selectedIndex: Binding<Int>,
         navigationStack: Binding<[(title: String, items: [MenuItem])]>,
         libraryType: LibraryType,
         artistOrAlbumName: String? = nil) {
        self._currentMenuItems = currentMenuItems
        self._selectedIndex = selectedIndex
        self._navigationStack = navigationStack
        self.libraryType = libraryType
        self.artistOrAlbumName = artistOrAlbumName
    }
    
    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .task {
                await loadLibraryContent()
            }
    }
    
    private func loadLibraryContent() async {
        print("Loading library content for type: \(libraryType)")
        await libraryService.loadMusicLibrary()
        
        await MainActor.run {
            print("Library loaded. Songs count: \(libraryService.songs.count)")
            switch libraryType {
            case .songs:
                if libraryService.isLoading {
                    let loadingItem = [MenuItem(title: "Loading songs...", icon: "hourglass", action: .custom { })]
                    currentMenuItems = loadingItem
                    navigationStack.append(("Songs", loadingItem))
                } else {
                    let songItems = libraryService.songs.isEmpty ? 
                        [MenuItem(title: "No songs found", icon: "exclamationmark.circle", action: .custom { })] :
                        libraryService.songs.map { song in
                            MenuItem(
                                title: song.title,
                                icon: nil,
                                action: .playSong(song)
                            )
                        }
                    currentMenuItems = songItems
                    navigationStack.append(("Songs", songItems))
                }
                selectedIndex = 0
                
            case .artists:
                let artistItems = libraryService.artists.isEmpty ?
                    [MenuItem(title: "No artists found", icon: "exclamationmark.circle", action: .custom { })] :
                    libraryService.artists.keys.sorted().map { artist in
                        MenuItem(
                            title: artist,
                            icon: "person",
                            action: .showArtistSongs(artist)
                        )
                    }
                currentMenuItems = artistItems
                navigationStack.append(("Artists", artistItems))
                selectedIndex = 0
                
            case .albums:
                let albumItems = libraryService.albums.keys.sorted().map { album in
                    MenuItem(
                        title: album,
                        icon: "square.stack",
                        action: .showAlbumSongs(album)
                    )
                }
                currentMenuItems = albumItems
                navigationStack.append(("Albums", albumItems))
                selectedIndex = 0
                
            case .playlists:
                let playlistItems = libraryService.playlists.map { playlist in
                    MenuItem(
                        title: playlist.name,
                        icon: "music.note.list",
                        action: .playPlaylist(playlist)
                    )
                }
                currentMenuItems = playlistItems
                navigationStack.append(("Playlists", playlistItems))
                selectedIndex = 0
                
            case .artistSongs:
                if let artist = artistOrAlbumName {
                    let songs = libraryService.getSongsForArtist(artist)
                    let songItems = songs.map { song in
                        MenuItem(
                            title: song.title,
                            icon: nil,
                            action: .playSong(song)
                        )
                    }
                    currentMenuItems = songItems
                    navigationStack.append((artist, songItems))
                    selectedIndex = 0
                }
                
            case .albumSongs:
                if let album = artistOrAlbumName {
                    let songs = libraryService.getSongsForAlbum(album)
                    let songItems = songs.map { song in
                        MenuItem(
                            title: song.title,
                            icon: nil,
                            action: .playSong(song)
                        )
                    }
                    currentMenuItems = songItems
                    navigationStack.append((album, songItems))
                    selectedIndex = 0
                }
            }
        }
    }
}