import Foundation

public struct Artist: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let name: String
    public let thumbnailURL: URL?
    public let subscriberCount: String?
    public let description: String?

    public init(
        id: String,
        name: String,
        thumbnailURL: URL? = nil,
        subscriberCount: String? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.name = name
        self.thumbnailURL = thumbnailURL
        self.subscriberCount = subscriberCount
        self.description = description
    }
}
