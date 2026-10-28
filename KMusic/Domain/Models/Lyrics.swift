import Foundation

public struct LyricLine: Identifiable, Hashable, Sendable {
    public var id: String { "\(timestamp)_\(text)" }
    public let timestamp: TimeInterval
    public let text: String

    public init(timestamp: TimeInterval, text: String) {
        self.timestamp = timestamp
        self.text = text
    }
}

public struct LyricsData: Sendable {
    public let id: String
    public let trackName: String
    public let artistName: String
    public let isSynced: Bool
    public let lines: [LyricLine]
    public let plainText: String

    public init(
        id: String,
        trackName: String,
        artistName: String,
        isSynced: Bool,
        lines: [LyricLine] = [],
        plainText: String = ""
    ) {
        self.id = id
        self.trackName = trackName
        self.artistName = artistName
        self.isSynced = isSynced
        self.lines = lines
        self.plainText = plainText
    }
}
