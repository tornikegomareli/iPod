import SwiftUI

struct NowPlayingView: View {
    @Binding var playerState: PlayerState
    @Binding var isPresented: Bool
    
    @State private var dragOffset: CGFloat = 0
    
    private let displayHeight: CGFloat = 300
    private let displayWidth: CGFloat = 340
    
    var body: some View {
        VStack(spacing: 0) {
            nowPlayingHeader
            
            if let song = playerState.currentSong {
                songInfoView(song: song)
                progressView
            } else {
                noSongView
            }
        }
        .frame(width: displayWidth, height: displayHeight)
        .background(iPodBackgroundGradient)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.3), lineWidth: 1)
        )
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    if value.translation.height < -50 {
                        withAnimation {
                            isPresented = false
                        }
                    } else {
                        withAnimation {
                            dragOffset = 0
                        }
                    }
                }
        )
    }
    
    private var nowPlayingHeader: some View {
        HStack {
            Text("Now Playing")
                .font(.custom("Chicago", size: 16))
                .fontWeight(.bold)
            
            Spacer()
            
            Image(systemName: playerState.repeatMode == .off ? "repeat" : 
                  playerState.repeatMode == .one ? "repeat.1" : "repeat")
                .font(.system(size: 12))
                .opacity(playerState.repeatMode == .off ? 0.3 : 1)
            
            Image(systemName: "shuffle")
                .font(.system(size: 12))
                .opacity(playerState.shuffleEnabled ? 1 : 0.3)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(white: 0.9))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.black.opacity(0.2)),
            alignment: .bottom
        )
    }
    
    private func songInfoView(song: Song) -> some View {
        VStack(spacing: 4) {
            if let artworkData = song.artworkData,
               let uiImage = UIImage(data: artworkData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .cornerRadius(4)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(white: 0.8))
                    .frame(height: 100)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            
            Text(song.title)
                .font(.custom("Chicago", size: 16))
                .fontWeight(.semibold)
                .lineLimit(1)
                .padding(.horizontal)
            
            Text(song.artist)
                .font(.custom("Chicago", size: 14))
                .foregroundColor(.gray)
                .lineLimit(1)
                .padding(.horizontal)
            
            Text(song.album)
                .font(.custom("Chicago", size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private var progressView: some View {
        VStack(spacing: 4) {
            ProgressBar(
                value: playerState.currentTime,
                maximum: playerState.currentSong?.duration ?? 1,
                isPlaying: playerState.isPlaying
            )
            .frame(height: 6)
            .padding(.horizontal, 20)
            
            HStack {
                Text(formatTime(playerState.currentTime))
                    .font(.custom("Chicago", size: 10))
                
                Spacer()
                
                Text("-\(formatTime((playerState.currentSong?.duration ?? 0) - playerState.currentTime))")
                    .font(.custom("Chicago", size: 10))
            }
            .padding(.horizontal, 20)
            .foregroundColor(.gray)
        }
        .padding(.bottom, 8)
    }
    
    private var noSongView: some View {
        VStack {
            Spacer()
            Text("No Song Playing")
                .font(.custom("Chicago", size: 16))
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    private var iPodBackgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.85, green: 0.88, blue: 0.85),
                Color(red: 0.75, green: 0.78, blue: 0.75)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct ProgressBar: View {
    let value: Double
    let maximum: Double
    let isPlaying: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(white: 0.3))
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * CGFloat(value / maximum))
                    .animation(.linear(duration: isPlaying ? 0.1 : 0), value: value)
            }
        }
    }
}