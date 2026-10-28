import SwiftUI

public struct LiquidDock: View {
    @Binding public var selectedTab: AppTab
    @Bindable private var player = AudioPlayerManager.shared

    public init(selectedTab: Binding<AppTab>) {
        self._selectedTab = selectedTab
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Floating MiniPlayer
            MiniPlayerView()
                .padding(.horizontal, 16)

            // Liquid Glass TabBar
            LiquidTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 16)
        }
        .padding(.bottom, 6)
    }
}
