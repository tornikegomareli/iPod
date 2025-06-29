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
        LinearGradient(
            colors: [
                Color(red: 0.85, green: 0.88, blue: 0.85),
                Color(red: 0.75, green: 0.78, blue: 0.75)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
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
            isSelected ? Color.blue : Color.clear
        )
    }
}