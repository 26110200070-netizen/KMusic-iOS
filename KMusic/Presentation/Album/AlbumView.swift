import SwiftUI

public struct AlbumView: View {
    @Bindable private var player = AudioPlayerManager.shared

    private let albums: [Album] = [
        Album(id: "album_1", title: "Bảo Tàng Của Nuối Tiếc", artistName: "Vũ.", thumbnailURL: URL(string: "https://i.ytimg.com/vi/Llw9Q6akRo4/hqdefault.jpg"), year: "2024", tracks: [
            Song(id: "Llw9Q6akRo4", title: "Lạ Lùng", artistName: "Vũ.", duration: 261, thumbnailURL: URL(string: "https://i.ytimg.com/vi/Llw9Q6akRo4/hqdefault.jpg"), videoId: "Llw9Q6akRo4"),
            Song(id: "vu_track2", title: "Bước Qua Nhau", artistName: "Vũ.", duration: 257, thumbnailURL: URL(string: "https://i.ytimg.com/vi/Llw9Q6akRo4/hqdefault.jpg"), videoId: "Llw9Q6akRo4"),
            Song(id: "vu_track3", title: "Những Lời Hứa Bỏ Quên", artistName: "Vũ.", duration: 235, thumbnailURL: URL(string: "https://i.ytimg.com/vi/Llw9Q6akRo4/hqdefault.jpg"), videoId: "Llw9Q6akRo4")
        ]),
        Album(id: "album_2", title: "m-tp M-TP", artistName: "Sơn Tùng M-TP", thumbnailURL: URL(string: "https://i.ytimg.com/vi/FN7ALfpGxiI/hqdefault.jpg"), year: "2017", tracks: [
            Song(id: "FN7ALfpGxiI", title: "Nơi Này Có Anh", artistName: "Sơn Tùng M-TP", duration: 260, thumbnailURL: URL(string: "https://i.ytimg.com/vi/FN7ALfpGxiI/hqdefault.jpg"), videoId: "FN7ALfpGxiI"),
            Song(id: "st_track2", title: "Lạc Trôi", artistName: "Sơn Tùng M-TP", duration: 242, thumbnailURL: URL(string: "https://i.ytimg.com/vi/FN7ALfpGxiI/hqdefault.jpg"), videoId: "FN7ALfpGxiI"),
            Song(id: "st_track3", title: "Chúng Ta Không Thuộc Về Nhau", artistName: "Sơn Tùng M-TP", duration: 235, thumbnailURL: URL(string: "https://i.ytimg.com/vi/FN7ALfpGxiI/hqdefault.jpg"), videoId: "FN7ALfpGxiI")
        ]),
        Album(id: "album_3", title: "LoiChoi", artistName: "Wren Evans", thumbnailURL: URL(string: "https://i.ytimg.com/vi/GgQKVsg_b0I/hqdefault.jpg"), year: "2024", tracks: [
            Song(id: "wren_1", title: "Từng Quen", artistName: "Wren Evans", duration: 180, thumbnailURL: URL(string: "https://i.ytimg.com/vi/GgQKVsg_b0I/hqdefault.jpg"), videoId: "GgQKVsg_b0I"),
            Song(id: "wren_2", title: "Cơn Đau Rất Muộn", artistName: "Wren Evans", duration: 210, thumbnailURL: URL(string: "https://i.ytimg.com/vi/GgQKVsg_b0I/hqdefault.jpg"), videoId: "GgQKVsg_b0I")
        ]),
        Album(id: "album_4", title: "Bật Nó Lên", artistName: "Soobin Hoàng Sơn", thumbnailURL: URL(string: "https://i.ytimg.com/vi/abPmZCZZrFA/hqdefault.jpg"), year: "2024", tracks: [
            Song(id: "abPmZCZZrFA", title: "Giá Như", artistName: "Soobin Hoàng Sơn", duration: 230, thumbnailURL: URL(string: "https://i.ytimg.com/vi/abPmZCZZrFA/hqdefault.jpg"), videoId: "abPmZCZZrFA")
        ]),
        Album(id: "album_5", title: "22", artistName: "MONO", thumbnailURL: URL(string: "https://i.ytimg.com/vi/psZ1g9fMfeo/hqdefault.jpg"), year: "2023", tracks: [
            Song(id: "mono_1", title: "Waiting For You", artistName: "MONO", duration: 265, thumbnailURL: URL(string: "https://i.ytimg.com/vi/psZ1g9fMfeo/hqdefault.jpg"), videoId: "psZ1g9fMfeo")
        ]),
        Album(id: "album_6", title: "Ái", artistName: "tlinh", thumbnailURL: URL(string: "https://i.ytimg.com/vi/FN7ALfpGxiI/hqdefault.jpg"), year: "2023", tracks: [
            Song(id: "tlinh_1", title: "Nếu Lúc Đó", artistName: "tlinh", duration: 245, thumbnailURL: URL(string: "https://i.ytimg.com/vi/FN7ALfpGxiI/hqdefault.jpg"), videoId: "FN7ALfpGxiI")
        ])
    ]

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Album")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .padding(.top, 8)

                    Text("Tuyển tập đĩa nhạc chất lượng cao")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.secondary)

                    // 2-Column Grid
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 20) {
                        ForEach(albums) { album in
                            Button {
                                if let first = album.tracks.first {
                                    player.play(song: first, newQueue: album.tracks)
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Color.gray.opacity(0.2))
                                            .aspectRatio(1, contentMode: .fit)

                                        if let thumb = album.thumbnailURL {
                                            AsyncImage(url: thumb) { phase in
                                                if let img = phase.image {
                                                    img.resizable()
                                                        .scaledToFill()
                                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                }
                                            }
                                        }
                                    }
                                    .shadow(color: Color.black.opacity(0.12), radius: 10, y: 5)

                                    Text(album.title)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color.primary)
                                        .lineLimit(1)

                                    Text("\(album.artistName) · \(album.year ?? "2024")")
                                        .font(.system(size: 13, weight: .regular))
                                        .foregroundStyle(Color.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .buttonStyle(.plain)
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
}
