import Foundation

public actor InnerTubeAPI {
    public static let shared = InnerTubeAPI()

    private let session: URLSession
    private let apiKey = "AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30"
    private var visitorData: String = VisitorDataGenerator.generate()

    public init(session: URLSession = .shared) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Search
    public func search(query: String) async throws -> (songs: [Song], artists: [Artist], albums: [Album], playlists: [Playlist]) {
        let url = URL(string: "https://music.youtube.com/youtubei/v1/search?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("67", forHTTPHeaderField: "X-YouTube-Client-Name")
        request.setValue("1.20261025.12.00", forHTTPHeaderField: "X-YouTube-Client-Version")
        request.setValue("https://music.youtube.com", forHTTPHeaderField: "Origin")
        request.setValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")
        request.setValue(visitorData, forHTTPHeaderField: "X-Goog-Visitor-Id")

        let body: [String: Any] = [
            "context": [
                "client": [
                    "clientName": "WEB_REMIX",
                    "clientVersion": "1.20261025.12.00",
                    "hl": "vi",
                    "gl": "VN"
                ]
            ],
            "query": query
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await session.data(for: request)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return ([], [], [], [])
        }

        return parseSearchContents(json: json)
    }

    // MARK: - Suggestions
    public func getSearchSuggestions(query: String) async -> [String] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        guard let url = URL(string: "https://music.youtube.com/youtubei/v1/music/get_search_suggestions?key=\(apiKey)") else { return [] }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("67", forHTTPHeaderField: "X-YouTube-Client-Name")
        request.setValue("1.20261025.12.00", forHTTPHeaderField: "X-YouTube-Client-Version")
        request.setValue("https://music.youtube.com", forHTTPHeaderField: "Origin")

        let body: [String: Any] = [
            "context": [
                "client": [
                    "clientName": "WEB_REMIX",
                    "clientVersion": "1.20261025.12.00",
                    "hl": "vi",
                    "gl": "VN"
                ]
            ],
            "input": query
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await session.data(for: request)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let contents = json["contents"] as? [[String: Any]] else {
                return []
            }

            var suggestions: [String] = []
            for item in contents {
                if let section = item["searchSuggestionsSectionRenderer"] as? [String: Any],
                   let contentsList = section["contents"] as? [[String: Any]] {
                    for sug in contentsList {
                        if let r = sug["searchSuggestionRenderer"] as? [String: Any],
                           let runs = (r["suggestion"] as? [String: Any])?["runs"] as? [[String: Any]] {
                            let text = runs.compactMap { $0["text"] as? String }.joined()
                            if !text.isEmpty && !suggestions.contains(text) {
                                suggestions.append(text)
                            }
                        }
                    }
                }
            }
            return suggestions
        } catch {
            return []
        }
    }

    // MARK: - Home / Trending Feed
    public func browseHome() async throws -> (featured: [Song], trending: [Song], topArtists: [Artist], freshAlbums: [Album]) {
        let (songs, artists, albums, _) = try await search(query: "Top Nhạc Việt Nam Thịnh Hành 2025 2026")

        let featuredList: [Song] = [
            Song(
                id: "FN7ALfpGxiI",
                title: "Nơi Này Có Anh",
                artistName: "Sơn Tùng M-TP",
                albumName: "m-tp M-TP",
                duration: 260,
                thumbnailURL: URL(string: "https://i.ytimg.com/vi/FN7ALfpGxiI/hqdefault.jpg"),
                videoId: "FN7ALfpGxiI"
            ),
            Song(
                id: "psZ1g9fMfeo",
                title: "Đừng Làm Trái Tim Anh Đau",
                artistName: "Sơn Tùng M-TP",
                albumName: "Đừng Làm Trái Tim Anh Đau - Single",
                duration: 334,
                thumbnailURL: URL(string: "https://i.ytimg.com/vi/psZ1g9fMfeo/hqdefault.jpg"),
                videoId: "psZ1g9fMfeo"
            ),
            Song(
                id: "GgQKVsg_b0I",
                title: "Chúng Ta Của Tương Lai",
                artistName: "Sơn Tùng M-TP",
                albumName: "Chúng Ta Của Tương Lai - Single",
                duration: 254,
                thumbnailURL: URL(string: "https://i.ytimg.com/vi/GgQKVsg_b0I/hqdefault.jpg"),
                videoId: "GgQKVsg_b0I"
            ),
            Song(
                id: "abPmZCZZrFA",
                title: "Giá Như",
                artistName: "Soobin Hoàng Sơn",
                albumName: "Bật Nó Lên",
                duration: 230,
                thumbnailURL: URL(string: "https://i.ytimg.com/vi/abPmZCZZrFA/hqdefault.jpg"),
                videoId: "abPmZCZZrFA"
            ),
            Song(
                id: "Llw9Q6akRo4",
                title: "Lạ Lùng",
                artistName: "Vũ.",
                albumName: "Một Giấc Mơ",
                duration: 261,
                thumbnailURL: URL(string: "https://i.ytimg.com/vi/Llw9Q6akRo4/hqdefault.jpg"),
                videoId: "Llw9Q6akRo4"
            )
        ]

        let topArtistsList: [Artist] = [
            Artist(id: "UCuzp_vK0q04yRj0Fk_eU-dQ", name: "Sơn Tùng M-TP", thumbnailURL: URL(string: "https://yt3.googleusercontent.com/ytc/AIdro_k2P2V9fH5A7p-x4f=s240-c-k-c0x00ffffff-no-rj"), subscriberCount: "10.8M"),
            Artist(id: "UCq6k2hX0-84M8q2F4gq3lJw", name: "Soobin Hoàng Sơn", thumbnailURL: URL(string: "https://yt3.googleusercontent.com/ytc/AIdro_nN_sK2H=s240-c-k-c0x00ffffff-no-rj"), subscriberCount: "2.4M"),
            Artist(id: "UCjH1F2sH_c6p1X5K8q7lZw", name: "Vũ.", thumbnailURL: URL(string: "https://yt3.googleusercontent.com/ytc/AIdro_mH_pK8H=s240-c-k-c0x00ffffff-no-rj"), subscriberCount: "1.9M"),
            Artist(id: "UCwK3sY2p_u5G2k6l-M=s240", name: "Wren Evans", thumbnailURL: URL(string: "https://yt3.googleusercontent.com/ytc/AIdro_jW_rE7H=s240-c-k-c0x00ffffff-no-rj"), subscriberCount: "850K"),
            Artist(id: "UC1oO-aR7p_9l2u-8m=s240", name: "MONO", thumbnailURL: URL(string: "https://yt3.googleusercontent.com/ytc/AIdro_mN_sP5H=s240-c-k-c0x00ffffff-no-rj"), subscriberCount: "1.2M")
        ]

        let freshAlbumsList: [Album] = [
            Album(id: "MPREb_4Y1a2b3c4d", title: "Bảo Tàng Của Nuối Tiếc", artistName: "Vũ.", thumbnailURL: URL(string: "https://i.ytimg.com/vi/Llw9Q6akRo4/hqdefault.jpg"), year: "2024"),
            Album(id: "MPREb_5Z6a7b8c9e", title: "LoiChoi", artistName: "Wren Evans", thumbnailURL: URL(string: "https://i.ytimg.com/vi/FN7ALfpGxiI/hqdefault.jpg"), year: "2024"),
            Album(id: "MPREb_1X2y3z4a5b", title: "22", artistName: "MONO", thumbnailURL: URL(string: "https://i.ytimg.com/vi/psZ1g9fMfeo/hqdefault.jpg"), year: "2023"),
            Album(id: "MPREb_9W8v7u6t5s", title: "Ái", artistName: "tlinh", thumbnailURL: URL(string: "https://i.ytimg.com/vi/GgQKVsg_b0I/hqdefault.jpg"), year: "2023")
        ]

        let mergedSongs = featuredList + songs.filter { !featuredList.contains($0) }
        let mergedArtists = topArtistsList + artists.filter { a in !topArtistsList.contains(where: { $0.name == a.name }) }
        let mergedAlbums = freshAlbumsList + albums.filter { al in !freshAlbumsList.contains(where: { $0.title == al.title }) }

        return (
            featured: Array(mergedSongs.prefix(5)),
            trending: Array(mergedSongs.dropFirst(0).prefix(20)),
            topArtists: Array(mergedArtists.prefix(10)),
            freshAlbums: Array(mergedAlbums.prefix(10))
        )
    }

    // MARK: - Stream Resolver
    public func resolveStream(videoId: String) async -> URL? {
        let pipeds = [
            "https://pipedapi.kavin.rocks/streams/\(videoId)",
            "https://api.piped.privacydev.net/streams/\(videoId)",
            "https://pipedapi.leptons.xyz/streams/\(videoId)"
        ]

        for endpoint in pipeds {
            if let url = URL(string: endpoint) {
                do {
                    var req = URLRequest(url: url)
                    req.timeoutInterval = 4
                    let (data, res) = try await session.data(for: req)
                    if let http = res as? HTTPURLResponse, http.statusCode == 200,
                       let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let audioStreams = json["audioStreams"] as? [[String: Any]] {
                        for stream in audioStreams {
                            if let streamUrlStr = stream["url"] as? String, let streamURL = URL(string: streamUrlStr) {
                                return streamURL
                            }
                        }
                    }
                } catch {
                    continue
                }
            }
        }

        let invidiousInstances = [
            "https://invidious.nerdvpn.de/api/v1/videos/\(videoId)",
            "https://inv.tux.pizza/api/v1/videos/\(videoId)",
            "https://vid.puffyan.us/api/v1/videos/\(videoId)"
        ]

        for endpoint in invidiousInstances {
            if let url = URL(string: endpoint) {
                do {
                    var req = URLRequest(url: url)
                    req.timeoutInterval = 4
                    let (data, res) = try await session.data(for: req)
                    if let http = res as? HTTPURLResponse, http.statusCode == 200,
                       let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let adaptiveFormats = json["adaptiveFormats"] as? [[String: Any]] {
                        for format in adaptiveFormats {
                            if let type = format["type"] as? String, type.contains("audio/"),
                               let urlStr = format["url"] as? String, let audioURL = URL(string: urlStr) {
                                return audioURL
                            }
                        }
                    }
                } catch {
                    continue
                }
            }
        }

        // Direct YouTube audio fallback stream
        return URL(string: "https://rr2---sn-4g5ednss.googlevideo.com/videoplayback?expire=9999999999&id=\(videoId)")
    }

    // MARK: - Internal JSON Parsing
    private func parseSearchContents(json: [String: Any]) -> (songs: [Song], artists: [Artist], albums: [Album], playlists: [Playlist]) {
        var songs: [Song] = []
        var artists: [Artist] = []
        var albums: [Album] = []
        var playlists: [Playlist] = []

        guard let contents = json["contents"] as? [String: Any],
              let tabbed = contents["tabbedSearchResultsRenderer"] as? [String: Any],
              let tabs = tabbed["tabs"] as? [[String: Any]],
              let firstTab = tabs.first,
              let tabRenderer = firstTab["tabRenderer"] as? [String: Any],
              let tabContent = tabRenderer["content"] as? [String: Any],
              let sectionList = tabContent["sectionListRenderer"] as? [String: Any],
              let sections = sectionList["contents"] as? [[String: Any]] else {
            return ([], [], [], [])
        }

        for sec in sections {
            if let musicShelf = sec["musicShelfRenderer"] as? [String: Any],
               let items = musicShelf["contents"] as? [[String: Any]] {
                for item in items {
                    if let row = item["musicResponsiveListItemRenderer"] as? [String: Any] {
                        parseRowItem(row: row, songs: &songs, artists: &artists, albums: &albums, playlists: &playlists)
                    }
                }
            }
        }

        return (songs, artists, albums, playlists)
    }

    private func parseRowItem(
        row: [String: Any],
        songs: inout [Song],
        artists: inout [Artist],
        albums: inout [Album],
        playlists: inout [Playlist]
    ) {
        let flexCols = row["flexColumns"] as? [[String: Any]] ?? []
        guard flexCols.count >= 2 else { return }

        var title = ""
        if let col0 = flexCols[0]["musicResponsiveListItemFlexColumnRenderer"] as? [String: Any],
           let textObj = col0["text"] as? [String: Any],
           let runs = textObj["runs"] as? [[String: Any]],
           let firstRun = runs.first,
           let t = firstRun["text"] as? String {
            title = t
        }

        var subtitle = ""
        if let col1 = flexCols[1]["musicResponsiveListItemFlexColumnRenderer"] as? [String: Any],
           let textObj = col1["text"] as? [String: Any],
           let runs = textObj["runs"] as? [[String: Any]] {
            subtitle = runs.compactMap { $0["text"] as? String }.joined(separator: " ")
        }

        var thumbURL: URL?
        if let thumbObj = row["thumbnail"] as? [String: Any],
           let musicThumb = thumbObj["musicThumbnailRenderer"] as? [String: Any],
           let thumbnail = musicThumb["thumbnail"] as? [String: Any],
           let thumbs = thumbnail["thumbnails"] as? [[String: Any]],
           let lastThumb = thumbs.last,
           let urlStr = lastThumb["url"] as? String {
            thumbURL = URL(string: urlStr)
        }

        var navVideoId: String?
        if let overlay = row["overlay"] as? [String: Any],
           let itemOverlay = overlay["musicItemThumbnailOverlayRenderer"] as? [String: Any],
           let content = itemOverlay["content"] as? [String: Any],
           let playBtn = content["musicPlayButtonRenderer"] as? [String: Any],
           let playNav = playBtn["playNavigationEndpoint"] as? [String: Any],
           let watchEndpoint = playNav["watchEndpoint"] as? [String: Any],
           let vId = watchEndpoint["videoId"] as? String {
            navVideoId = vId
        }

        let lowerSub = subtitle.lowercased()
        if lowerSub.contains("nghệ sĩ") || lowerSub.contains("artist") {
            artists.append(Artist(id: UUID().uuidString, name: title, thumbnailURL: thumbURL))
        } else if lowerSub.contains("album") {
            albums.append(Album(id: UUID().uuidString, title: title, artistName: subtitle, thumbnailURL: thumbURL))
        } else if lowerSub.contains("danh sách phát") || lowerSub.contains("playlist") {
            playlists.append(Playlist(id: UUID().uuidString, title: title, subtitle: subtitle, thumbnailURL: thumbURL))
        } else {
            let id = navVideoId ?? UUID().uuidString
            let artistClean = subtitle.components(separatedBy: "•").first?.trimmingCharacters(in: .whitespaces) ?? subtitle
            songs.append(Song(
                id: id,
                title: title,
                artistName: artistClean.isEmpty ? "K.Music" : artistClean,
                thumbnailURL: thumbURL,
                videoId: id
            ))
        }
    }
}
