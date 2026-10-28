import SwiftUI

public struct MiniPlayerView: View {
    @Bindable private var player = AudioPlayerManager.shared

    public init() {}

    public var body: some View {
        Button {
            if player.currentSong != nil {
                player.isFullPlayerPresented = true
            }
        } label: {
            HStack(spacing: 12) {
                // Artwork / Note icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.red.opacity(0.18))
                        .frame(width: 42, height: 42)

                    if let thumb = player.currentSong?.thumbnailURL {
                        AsyncImage(url: thumb) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 42, height: 42)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            default:
                                Image(systemName: "music.note")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color.red)
                            }
                        }
                    } else {
                        Image(systemName: "music.note")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.red)
                    }
                }

                // Song Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.currentSong?.title ?? "Không phát")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)

                    if let artist = player.currentSong?.artistName {
                        Text(artist)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Play / Pause Button
                Button {
                    player.togglePlayPause()
                } label: {
                    if player.isBuffering {
                        ProgressView()
                            .scaleEffect(0.85)
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.primary)
                            .frame(width: 36, height: 36)
                    }
                }
                .buttonStyle(.plain)

                // Skip Next Button
                Button {
                    player.next()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .liquidGlass(shape: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}
