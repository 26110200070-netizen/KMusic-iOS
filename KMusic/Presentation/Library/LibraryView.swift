import SwiftUI

public struct LibraryView: View {
    @Bindable private var player = AudioPlayerManager.shared

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Thư viện")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .padding(.top, 8)

                    // Quick Action Rows
                    VStack(spacing: 12) {
                        libraryActionRow(icon: "heart.fill", color: .red, title: "Bài hát yêu thích", count: "\(player.favoriteSongIds.count)")
                        libraryActionRow(icon: "arrow.down.circle.fill", color: .blue, title: "Đã tải về", count: "Offline")
                        libraryActionRow(icon: "clock.fill", color: .orange, title: "Đã nghe gần đây", count: "\(player.queue.count)")
                        libraryActionRow(icon: "music.note.list", color: .purple, title: "Playlist của tôi", count: "3")
                    }

                    // Recently played / In queue
                    Text("Đang trong hàng đợi")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .padding(.top, 12)

                    if player.queue.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "music.quarternote.3")
                                .font(.system(size: 44))
                                .foregroundStyle(Color.secondary)
                            Text("Chưa có bài hát nào trong hàng đợi")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 120)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(player.queue) { song in
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 48, height: 48)

                                        if let thumb = song.thumbnailURL {
                                            AsyncImage(url: thumb) { phase in
                                                if let img = phase.image {
                                                    img.resizable()
                                                        .scaledToFill()
                                                        .frame(width: 48, height: 48)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                                }
                                            }
                                        }
                                    }

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

                                    if player.currentSong?.id == song.id && player.isPlaying {
                                        Image(systemName: "speaker.wave.3.fill")
                                            .foregroundStyle(Color.red)
                                    }
                                }
                                .onTapGesture {
                                    player.play(song: song)
                                }
                            }
                        }
                    }

                    Spacer()
                        .frame(height: 120)
                }
                .padding(.horizontal, 16)
            }
            .navigationBarHidden(true)
        }
    }

    private func libraryActionRow(icon: String, color: Color, title: String, count: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.primary)

            Spacer()

            Text(count)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.secondary)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .padding(.vertical, 4)
    }
}
