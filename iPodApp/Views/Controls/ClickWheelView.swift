import SwiftUI

struct ClickWheelView: View {
    @Binding var selectedIndex: Int
    let itemCount: Int
    let onCenterTap: () -> Void
    let onMenuTap: () -> Void
    let onPlayPauseTap: () -> Void
    let onNextTap: () -> Void
    let onPreviousTap: () -> Void
    let isBlackiPod: Bool
    
    @State private var angle: Double = 0
    @State private var lastAngle: Double = 0
    @State private var accumulatedRotation: Double = 0
    
    private let wheelSize: CGFloat = 220
    private let centerButtonSize: CGFloat = 80
    
    var body: some View {
        ZStack {
            wheelBackground
            
            controlButtons
            
            centerButton
        }
        .frame(width: wheelSize, height: wheelSize)
        .gesture(wheelGesture)
    }
    
    private var wheelBackground: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: isBlackiPod ? [
                        Color(white: 0.2),
                        Color(white: 0.05)
                    ] : [
                        Color(white: 0.9),
                        Color(white: 0.95)
                    ],
                    center: .center,
                    startRadius: 40,
                    endRadius: 110
                )
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: isBlackiPod ? [
                                Color(white: 0.4),
                                Color(white: 0.1)
                            ] : [
                                Color(white: 0.6),
                                Color(white: 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: .black.opacity(isBlackiPod ? 0.5 : 0.2), radius: 8, x: 0, y: 4)
    }
    
    private var controlButtons: some View {
        Group {
            Button(action: onMenuTap) {
                Text("MENU")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isBlackiPod ? .gray : Color(white: 0.3))
            }
            .position(x: wheelSize / 2, y: 30)
            
            Button(action: onPreviousTap) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 16))
                    .foregroundColor(isBlackiPod ? .gray : Color(white: 0.3))
            }
            .position(x: 30, y: wheelSize / 2)
            
            Button(action: onNextTap) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 16))
                    .foregroundColor(isBlackiPod ? .gray : Color(white: 0.3))
            }
            .position(x: wheelSize - 30, y: wheelSize / 2)
            
            Button(action: onPlayPauseTap) {
                Image(systemName: "playpause.fill")
                    .font(.system(size: 16))
                    .foregroundColor(isBlackiPod ? .gray : Color(white: 0.3))
            }
            .position(x: wheelSize / 2, y: wheelSize - 30)
        }
    }
    
    private var centerButton: some View {
        Button(action: onCenterTap) {
            Circle()
                .fill(
                    RadialGradient(
                        colors: isBlackiPod ? [
                            Color(white: 0.3),
                            Color(white: 0.2)
                        ] : [
                            Color(white: 0.9),
                            Color(white: 0.8)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .frame(width: centerButtonSize, height: centerButtonSize)
                .overlay(
                    Circle()
                        .stroke(Color(white: isBlackiPod ? 0.4 : 0.6), lineWidth: 1)
                )
        }
    }
    
    private var wheelGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let center = CGPoint(x: wheelSize / 2, y: wheelSize / 2)
                let location = value.location
                
                let deltaX = location.x - center.x
                let deltaY = location.y - center.y
                let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
                
                guard distance > centerButtonSize / 2 && distance < wheelSize / 2 else { return }
                
                let newAngle = atan2(deltaY, deltaX)
                
                if lastAngle != 0 {
                    var deltaAngle = newAngle - lastAngle
                    
                    if deltaAngle > Double.pi {
                        deltaAngle -= 2 * Double.pi
                    } else if deltaAngle < -Double.pi {
                        deltaAngle += 2 * Double.pi
                    }
                    
                    accumulatedRotation += deltaAngle
                    
                    let rotationThreshold = Double.pi / 12
                    if abs(accumulatedRotation) > rotationThreshold {
                        if accumulatedRotation > 0 {
                            selectedIndex = min(selectedIndex + 1, itemCount - 1)
                        } else {
                            selectedIndex = max(selectedIndex - 1, 0)
                        }
                        accumulatedRotation = 0
                        
                        HapticFeedbackManager.shared.wheelClick()
                    }
                }
                
                lastAngle = newAngle
            }
            .onEnded { _ in
                lastAngle = 0
                accumulatedRotation = 0
            }
    }
}