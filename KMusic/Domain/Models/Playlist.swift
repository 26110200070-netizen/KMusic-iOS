import Foundation

public struct Playlist: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let description: String?
    public let thumbnailURL: URL?
    public var tracks: [Song]

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        thumbnailURL: URL? = nil,
        tracks: [Song] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.tracks = tracks
    }
}
