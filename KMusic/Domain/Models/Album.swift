import Foundation

public struct Album: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let title: String
    public let artistName: String
    public let thumbnailURL: URL?
    public let year: String?
    public var tracks: [Song]

    public init(
        id: String,
        title: String,
        artistName: String,
        thumbnailURL: URL? = nil,
        year: String? = nil,
        tracks: [Song] = []
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.thumbnailURL = thumbnailURL
        self.year = year
        self.tracks = tracks
    }
}
