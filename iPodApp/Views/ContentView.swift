import SwiftUI

struct ContentView: View {
    @State private var currentMenuItems = MenuItem.mainMenuItems
    @State private var selectedIndex = 0
    @State private var navigationStack: [(title: String, items: [MenuItem])] = [("iPod", MenuItem.mainMenuItems)]
    @StateObject private var playerViewModel = MusicPlayerViewModel()
    @State private var showNowPlaying = false
    @State private var isBlackiPod = true
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isBlackiPod.toggle()
                        }
                    }) {
                        Image(systemName: isBlackiPod ? "moon.fill" : "sun.max.fill")
                            .font(.system(size: 24))
                            .foregroundColor(isBlackiPod ? .white : .yellow)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                    .padding()
                }
                
                Spacer()
                
                iPodDeviceView
                
                Spacer()
            }
        }
    }
    
    private var iPodDeviceView: some View {
        VStack(spacing: 0) {
            /// iPod body
            ZStack {
                /// Device frame
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: isBlackiPod ? [
                                Color(white: 0.15),
                                Color(white: 0.05)
                            ] : [
                                Color(white: 0.95),
                                Color(white: 0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                LinearGradient(
                                    colors: isBlackiPod ? [
                                        Color(white: 0.3),
                                        Color(white: 0.1)
                                    ] : [
                                        Color(white: 0.7),
                                        Color(white: 0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                VStack(spacing: 25) {
                    /// Display area with bezel
                    ZStack {
                        /// Display bezel
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(white: isBlackiPod ? 0.05 : 0.85))
                            .frame(width: 360, height: 320)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(white: isBlackiPod ? 0.2 : 0.6), lineWidth: 2)
                            )
                        
                        /// Display content
                        if showNowPlaying {
                            NowPlayingView(
                                playerState: $playerViewModel.playerState,
                                isPresented: $showNowPlaying
                            )
                        } else {
                            iPodDisplayView(
                                menuItems: $currentMenuItems,
                                selectedIndex: $selectedIndex,
                                title: navigationStack.last?.title ?? "iPod"
                            )
                        }
                    }
                    .padding(.top, 40)
                    
                    /// Click wheel area
                    ClickWheelView(
                        selectedIndex: $selectedIndex,
                        itemCount: currentMenuItems.count,
                        onCenterTap: handleCenterTap,
                        onMenuTap: handleMenuTap,
                        onPlayPauseTap: handlePlayPause,
                        onNextTap: handleNext,
                        onPreviousTap: handlePrevious,
                        isBlackiPod: isBlackiPod
                    )
                    .padding(.bottom, 30)
                }
            }
            .frame(width: 400, height: 680)
            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
        }
    }
    
    private func handleCenterTap() {
        guard selectedIndex < currentMenuItems.count else { return }
        let selectedItem = currentMenuItems[selectedIndex]
        
        switch selectedItem.action {
        case .navigate(let items):
            navigationStack.append((selectedItem.title, items))
            currentMenuItems = items
            selectedIndex = 0
        case .showNowPlaying:
            showNowPlaying = true
        case .playSong(let song):
            playerViewModel.playSong(song)
            showNowPlaying = true
        case .playPlaylist(let playlist):
            playerViewModel.playPlaylist(playlist)
            showNowPlaying = true
        case .showSettings:
            print("Show settings")
        case .custom(let action):
            action()
        }
    }
    
    private func handleMenuTap() {
        if showNowPlaying {
            showNowPlaying = false
        } else if navigationStack.count > 1 {
            navigationStack.removeLast()
            let previous = navigationStack.last!
            currentMenuItems = previous.items
            selectedIndex = 0
        }
    }
    
    private func handlePlayPause() {
        playerViewModel.togglePlayPause()
    }
    
    private func handleNext() {
        playerViewModel.nextTrack()
    }
    
    private func handlePrevious() {
        playerViewModel.previousTrack()
    }
}

#Preview {
    ContentView()
}
