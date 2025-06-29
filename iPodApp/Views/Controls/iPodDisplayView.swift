import SwiftUI

struct iPodDisplayView: View {
    @Binding var menuItems: [MenuItem]
    @Binding var selectedIndex: Int
    let title: String
    
    private let displayHeight: CGFloat = 300
    private let displayWidth: CGFloat = 340
    private let itemHeight: CGFloat = 36
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(Array(menuItems.enumerated()), id: \.element.id) { index, item in
                            MenuItemRow(
                                item: item,
                                isSelected: index == selectedIndex
                            )
                            .frame(height: itemHeight)
                            .id(index)
                        }
                    }
                }
                .onChange(of: selectedIndex) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
        .frame(width: displayWidth, height: displayHeight)
        .background(iPodBackgroundGradient)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var headerView: some View {
        HStack {
            Text(title)
                .font(.custom("Chicago", size: 18))
                .fontWeight(.bold)
            
            Spacer()
            
            Image(systemName: "battery.75")
                .font(.system(size: 12))
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
    
    private var iPodBackgroundGradient: some View {
        ZStack {
            /// Base LCD color
            LinearGradient(
                colors: [
                    Color(red: 0.85, green: 0.88, blue: 0.85),
                    Color(red: 0.75, green: 0.78, blue: 0.75)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            /// LCD pixel grid effect
            LCDPixelGrid()
            
            /// LCD ghosting/shimmer effect
            LinearGradient(
                colors: [
                    Color.white.opacity(0.03),
                    Color.clear,
                    Color.black.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            /// LCD contrast/depth effect
            VStack {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
                .frame(height: 30)
                
                Spacer()
                
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.05)
                    ],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 30)
            }
        }
    }
}

struct LCDPixelGrid: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let pixelSize: CGFloat = 2
                let spacing: CGFloat = 0.5
                let totalSize = pixelSize + spacing
                
                let columns = Int(size.width / totalSize)
                let rows = Int(size.height / totalSize)
                
                for row in 0..<rows {
                    for col in 0..<columns {
                        let x = CGFloat(col) * totalSize
                        let y = CGFloat(row) * totalSize
                        
                        let rect = CGRect(x: x, y: y, width: pixelSize, height: pixelSize)
                        
                        /// Create subtle pixel variation
                        let opacity = 0.02 + Double((row + col) % 3) * 0.01
                        context.fill(
                            Path(rect),
                            with: .color(.black.opacity(opacity))
                        )
                    }
                }
            }
        }
    }
}

struct MenuItemRow: View {
    let item: MenuItem
    let isSelected: Bool
    
    var body: some View {
        HStack {
            if let icon = item.icon {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 20)
            }
            
            Text(item.title)
                .font(.custom("Chicago", size: 16))
                .lineLimit(1)
            
            Spacer()
            
            if item.children != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
            }
        }
        .padding(.horizontal, 12)
        .foregroundColor(isSelected ? .white : .black)
        .background(
            isSelected ? Color.blue.opacity(0.9) : Color.clear
        )
        .overlay(
            /// LCD text shadow effect for unselected items
            isSelected ? nil : HStack {
                if let icon = item.icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .frame(width: 20)
                }
                
                Text(item.title)
                    .font(.custom("Chicago", size: 16))
                    .lineLimit(1)
                
                Spacer()
                
                if item.children != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                }
            }
            .padding(.horizontal, 12)
            .foregroundColor(.black.opacity(0.03))
            .offset(x: 1, y: 1)
        )
    }
}