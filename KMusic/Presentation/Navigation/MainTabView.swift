import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @Bindable private var player = AudioPlayerManager.shared

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .search:
                    SearchView()
                case .library:
                    LibraryView()
                case .album:
                    AlbumView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Floating Liquid Glass Dock
            LiquidDock(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $player.isFullPlayerPresented) {
            FullPlayerView()
                .presentationDragIndicator(.visible)
        }
    }
}
