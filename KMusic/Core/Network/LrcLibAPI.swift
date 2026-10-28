import Foundation

public actor LrcLibAPI {
    public static let shared = LrcLibAPI()
    private let session = URLSession.shared

    public func getLyrics(trackName: String, artistName: String, duration: TimeInterval? = nil) async -> LyricsData? {
        var components = URLComponents(string: "https://lrclib.net/api/get")!
        var queryItems = [
            URLQueryItem(name: "track_name", value: trackName),
            URLQueryItem(name: "artist_name", value: artistName)
        ]
        if let duration, duration > 0 {
            queryItems.append(URLQueryItem(name: "duration", value: "\(Int(duration))"))
        }
        components.queryItems = queryItems

        guard let url = components.url else { return nil }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 6
            request.setValue("KMusic-iOS/1.0", forHTTPHeaderField: "User-Agent")

            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200,
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return nil
            }

            let id = "\(json["id"] ?? UUID().uuidString)"
            let track = json["trackName"] as? String ?? trackName
            let artist = json["artistName"] as? String ?? artistName
            let plainLyrics = json["plainLyrics"] as? String ?? ""
            let syncedLyrics = json["syncedLyrics"] as? String ?? ""

            if !syncedLyrics.isEmpty {
                let lines = parseSyncedLyrics(syncedLyrics)
                return LyricsData(
                    id: id,
                    trackName: track,
                    artistName: artist,
                    isSynced: true,
                    lines: lines,
                    plainText: plainLyrics
                )
            } else if !plainLyrics.isEmpty {
                return LyricsData(
                    id: id,
                    trackName: track,
                    artistName: artist,
                    isSynced: false,
                    lines: [],
                    plainText: plainLyrics
                )
            }
            return nil
        } catch {
            return nil
        }
    }

    private func parseSyncedLyrics(_ lrc: String) -> [LyricLine] {
        var lines: [LyricLine] = []
        let rawLines = lrc.components(separatedBy: "\n")

        for line in rawLines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("[") else { continue }

            if let closeBracket = trimmed.firstIndex(of: "]") {
                let timeStr = String(trimmed[trimmed.index(after: trimmed.startIndex)..<closeBracket])
                let text = String(trimmed[trimmed.index(after: closeBracket)...]).trimmingCharacters(in: .whitespaces)

                if let seconds = parseTimestamp(timeStr) {
                    lines.append(LyricLine(timestamp: seconds, text: text))
                }
            }
        }

        return lines.sorted { $0.timestamp < $1.timestamp }
    }

    private func parseTimestamp(_ str: String) -> TimeInterval? {
        let parts = str.components(separatedBy: ":")
        guard parts.count == 2,
              let min = Double(parts[0]),
              let sec = Double(parts[1]) else { return nil }
        return min * 60 + sec
    }
}
