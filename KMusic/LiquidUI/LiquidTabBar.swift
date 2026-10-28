import SwiftUI

public enum AppTab: String, CaseIterable, Identifiable {
    case home = "KhoaHome"
    case search = "Tìm kiếm"
    case library = "Thư viện"
    case album = "Album"

    public var id: String { rawValue }

    public var title: String { rawValue }

    public var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .library: return "music.note.list"
        case .album: return "square.stack.fill"
        }
    }
}

public struct LiquidTabBar: View {
    @Binding public var selectedTab: AppTab
    @Namespace private var selectionNamespace

    public init(selectedTab: Binding<AppTab>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                let isSelected = selectedTab == tab

                Button {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        selectedTab = tab
                    }
                } label: {
                    ZStack {
                        if isSelected {
                            Capsule()
                                .fill(Color.primary.opacity(0.12))
                                .overlay {
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 0.75)
                                }
                                .matchedGeometryEffect(id: "liquid_tab_active", in: selectionNamespace)
                        }

                        VStack(spacing: 3) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 19, weight: .semibold))

                            Text(tab.title)
                                .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                                .lineLimit(1)
                        }
                        .foregroundStyle(isSelected ? Color.red : Color.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .liquidGlass(shape: Capsule())
        .shadow(color: Color.black.opacity(0.15), radius: 18, x: 0, y: 8)
    }
}
