import SwiftUI

public struct HomeView: View {
    @Bindable private var player = AudioPlayerManager.shared
    @State private var featuredSongs: [Song] = []
    @State private var trendingSongs: [Song] = []
    @State private var topArtists: [Artist] = []
    @State private var freshAlbums: [Album] = []
    @State private var isLoading: Bool = true

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Top Bar Header
                    headerBar

                    // Hero Card 1 (Apple Music red gradient card)
                    heroCardPrimary

                    // Hero Card 2 (Family plan card)
                    heroCardSecondary

                    // Music sections outside - unboxed clean designer layout
                    featuredSection

                    // Top Artists Strip
                    artistsSection

                    // Fresh Albums Horizontal Strip
                    albumsSection

                    // Top Chart Vietnam
                    trendingSection

                    // Bottom spacing for Floating Liquid Dock
                    Spacer()
                        .frame(height: 120)
                }
                .padding(.horizontal, 16)
            }
            .navigationBarHidden(true)
            .task {
                await loadHomeData()
            }
        }
    }

    // MARK: - Header
    private var headerBar: some View {
        HStack(alignment: .center) {
            Text("Trang chủ")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color.primary)

            Spacer()

            // User Avatar (Khoa)
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.red, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)

                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Hero Cards
    private var heroCardPrimary: some View {
        ZStack(alignment: .bottomLeading) {
            // Vivid Red Gradient background exactly matching Image 1
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.08, blue: 0.24),
                            Color(red: 0.88, green: 0.04, blue: 0.20),
                            Color(red: 0.72, green: 0.02, blue: 0.16)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .center, spacing: 20) {
                Text("Âm nhạc chỉ dành cho bạn. Miễn phí 1 tháng.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 28)
                    .padding(.horizontal, 24)

                Spacer(minLength: 40)

                // K.Music / Apple Music Logo
                HStack(spacing: 6) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Music")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.white)
                }

                Spacer(minLength: 40)

                // CTA Button
                VStack(spacing: 6) {
                    Text("Chấp nhận dùng thử miễn phí")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("1 tháng miễn phí, sau đó là 65.000 đ/tháng.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 380)
        .shadow(color: Color.red.opacity(0.3), radius: 20, y: 10)
    }

    private var heroCardSecondary: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.92, green: 0.05, blue: 0.35),
                            Color(red: 0.80, green: 0.02, blue: 0.45)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 8) {
                Text("Âm nhạc cho cả gia đình. Miễn phí 1 tháng.")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .frame(height: 120)
        .shadow(color: Color.pink.opacity(0.25), radius: 14, y: 6)
    }

    // MARK: - Open Unboxed Music Sections
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Bài Hát Nổi Bật")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.primary)

                Spacer()

                Text("Tất cả")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.red)
            }

            VStack(spacing: 12) {
                ForEach(featuredSongs) { song in
                    songRow(song: song)
                }
            }
        }
    }

    private var artistsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Nghệ Sĩ Nổi Bật")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(topArtists) { artist in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 80, height: 80)

                                if let thumb = artist.thumbnailURL {
                                    AsyncImage(url: thumb) { phase in
                                        if let img = phase.image {
                                            img.resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                            }
                            .overlay(Circle().stroke(Color.red.opacity(0.3), lineWidth: 1.5))

                            Text(artist.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.primary)
                                .lineLimit(1)
                                .frame(width: 84)

                            if let subs = artist.subscriberCount {
                                Text(subs)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundStyle(Color.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
        }
    }

    private var albumsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Album Mới Phát Hành")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(freshAlbums) { album in
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 140, height: 140)

                                if let thumb = album.thumbnailURL {
                                    AsyncImage(url: thumb) { phase in
                                        if let img = phase.image {
                                            img.resizable()
                                                .scaledToFill()
                                                .frame(width: 140, height: 140)
                                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        }
                                    }
                                }
                            }
                            .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)

                            Text(album.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.primary)
                                .lineLimit(1)
                                .frame(width: 140, alignment: .leading)

                            Text(album.artistName)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(Color.secondary)
                                .lineLimit(1)
                                .frame(width: 140, alignment: .leading)
                        }
                    }
                }
            }
        }
    }

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Bảng Xếp Hạng Top 100")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.primary)

            VStack(spacing: 12) {
                ForEach(Array(trendingSongs.enumerated()), id: \.element.id) { index, song in
                    HStack(spacing: 14) {
                        Text("\(index + 1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(index < 3 ? Color.red : Color.secondary)
                            .frame(width: 24, alignment: .center)

                        songRow(song: song)
                    }
                }
            }
        }
    }

    // MARK: - Clean Unboxed Song Row
    private func songRow(song: Song) -> some View {
        Button {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            player.play(song: song, newQueue: featuredSongs + trendingSongs)
        } label: {
            HStack(spacing: 14) {
                // Square Artwork
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 52, height: 52)

                    if let thumb = song.thumbnailURL {
                        AsyncImage(url: thumb) { phase in
                            if let img = phase.image {
                                img.resizable()
                                    .scaledToFill()
                                    .frame(width: 52, height: 52)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                    } else {
                        Image(systemName: "music.note")
                            .foregroundStyle(Color.red)
                    }
                }

                // Title & Artist
                VStack(alignment: .leading, spacing: 3) {
                    Text(song.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(player.currentSong?.id == song.id ? Color.red : Color.primary)
                        .lineLimit(1)

                    Text(song.artistName)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Actions Button
                Button {
                    // Menu
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func loadHomeData() async {
        do {
            let data = try await InnerTubeAPI.shared.browseHome()
            self.featuredSongs = data.featured
            self.trendingSongs = data.trending
            self.topArtists = data.topArtists
            self.freshAlbums = data.freshAlbums
            self.isLoading = false
        } catch {
            self.isLoading = false
        }
    }
}
