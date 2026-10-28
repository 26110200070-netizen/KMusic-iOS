import Foundation

public struct Song: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let title: String
    public let artistName: String
    public let albumName: String?
    public let duration: TimeInterval
    public let thumbnailURL: URL?
    public let videoId: String
    public var audioStreamURL: URL?

    public init(
        id: String,
        title: String,
        artistName: String,
        albumName: String? = nil,
        duration: TimeInterval = 0,
        thumbnailURL: URL? = nil,
        videoId: String? = nil,
        audioStreamURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.albumName = albumName
        self.duration = duration
        self.thumbnailURL = thumbnailURL
        self.videoId = videoId ?? id
        self.audioStreamURL = audioStreamURL
    }

    public var formattedDuration: String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
