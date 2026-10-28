import SwiftUI

public struct FullPlayerView: View {
    @Bindable private var player = AudioPlayerManager.shared
    @State private var isDraggingSlider: Bool = false
    @State private var sliderValue: Double = 0
    @State private var showLyrics: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            // Background blur of current artwork
            if let thumb = player.currentSong?.thumbnailURL {
                AsyncImage(url: thumb) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            .blur(radius: 60)
                            .overlay(Color.black.opacity(0.55))
                    } else {
                        Color.black.opacity(0.85).ignoresSafeArea()
                    }
                }
            } else {
                LinearGradient(
                    colors: [Color.red.opacity(0.6), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                // Top Dismiss Bar
                HStack {
                    Button {
                        player.isFullPlayerPresented = false
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(12)
                    }

                    Spacer()

                    Text("K.Music")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            showLyrics.toggle()
                        }
                    } label: {
                        Image(systemName: showLyrics ? "quote.bubble.fill" : "quote.bubble")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(showLyrics ? Color.red : Color.white.opacity(0.8))
                            .padding(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                if showLyrics {
                    // Synced Lyrics View
                    lyricsScrollView
                } else {
                    // Artwork & Track Details
                    mainPlayerView
                }
            }
        }
    }

    private var mainPlayerView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Large Artwork
            ZStack {
                if let thumb = player.currentSong?.thumbnailURL {
                    AsyncImage(url: thumb) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()
                                .frame(width: 320, height: 320)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .shadow(color: Color.black.opacity(0.4), radius: 24, y: 12)
                        default:
                            fallbackArtwork
                        }
                    }
                } else {
                    fallbackArtwork
                }
            }
            .frame(width: 320, height: 320)

            Spacer()

            // Title, Artist & Like Button
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.currentSong?.title ?? "Không phát")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(player.currentSong?.artistName ?? "K.Music")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }

                Spacer()

                if let song = player.currentSong {
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        player.toggleFavorite(song: song)
                    } label: {
                        Image(systemName: player.isFavorite(song: song) ? "heart.fill" : "heart")
                            .font(.system(size: 24))
                            .foregroundStyle(player.isFavorite(song: song) ? Color.red : Color.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 32)

            // Scrubber Slider
            VStack(spacing: 8) {
                Slider(
                    value: Binding(
                        get: { isDraggingSlider ? sliderValue : player.currentTime },
                        set: { sliderValue = $0 }
                    ),
                    in: 0...max(player.duration, 1),
                    onEditingChanged: { editing in
                        isDraggingSlider = editing
                        if !editing {
                            player.seek(to: sliderValue)
                        }
                    }
                )
                .tint(Color.white)

                HStack {
                    Text(formatTime(player.currentTime))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.white.opacity(0.6))

                    Spacer()

                    Text("-" + formatTime(max(0, player.duration - player.currentTime)))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 32)

            // Playback Controls
            HStack(spacing: 36) {
                // Shuffle
                Button {
                    player.toggleShuffle()
                } label: {
                    Image(systemName: "shuffle")
                        .font(.system(size: 20))
                        .foregroundStyle(player.isShuffle ? Color.red : Color.white.opacity(0.6))
                }

                // Previous
                Button {
                    player.previous()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }

                // Play / Pause (Large Center)
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .heavy)
                    impact.impactOccurred()
                    player.togglePlayPause()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 68, height: 68)
                            .shadow(color: Color.white.opacity(0.2), radius: 12, y: 4)

                        if player.isBuffering {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.black)
                                .offset(x: player.isPlaying ? 0 : 2)
                        }
                    }
                }
                .buttonStyle(.plain)

                // Next
                Button {
                    player.next()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }

                // Repeat
                Button {
                    player.toggleRepeat()
                } label: {
                    Image(systemName: repeatIconName)
                        .font(.system(size: 20))
                        .foregroundStyle(player.repeatMode != .off ? Color.red : Color.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    private var lyricsScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    if let lyrics = player.currentLyrics, !lyrics.lines.isEmpty {
                        ForEach(Array(lyrics.lines.enumerated()), id: \.offset) { index, line in
                            let isActive = index == player.currentLyricIndex

                            Text(line.text)
                                .font(.system(size: isActive ? 24 : 19, weight: isActive ? .bold : .medium))
                                .foregroundStyle(isActive ? .white : .white.opacity(0.4))
                                .scaleEffect(isActive ? 1.05 : 1.0, anchor: .leading)
                                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isActive)
                                .id(index)
                                .onTapGesture {
                                    player.seek(to: line.timestamp)
                                }
                        }
                    } else if let plain = player.currentLyrics?.plainText, !plain.isEmpty {
                        Text(plain)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .lineSpacing(6)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "music.mic")
                                .font(.system(size: 40))
                                .foregroundStyle(.white.opacity(0.4))
                            Text("Chưa có lời cho bài hát này")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 32)
            }
            .onChange(of: player.currentLyricIndex) { _, newIndex in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }

    private var fallbackArtwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [Color.red.opacity(0.4), Color.purple.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 320, height: 320)

            Image(systemName: "music.note")
                .font(.system(size: 80))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var repeatIconName: String {
        switch player.repeatMode {
        case .off, .all: return "repeat"
        case .one: return "repeat.1"
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
