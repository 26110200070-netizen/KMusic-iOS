import Foundation

public struct VisitorDataGenerator {
    private static let idCharset = Array(
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
    )

    public static func generate() -> String {
        let id = generateRandomID(length: 11)
        let timestamp = UInt64(Date().timeIntervalSince1970)
        let proto = encodeProtobuf(id: id, timestamp: timestamp)
        return proto.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private static func generateRandomID(length: Int) -> String {
        String((0..<length).compactMap { _ in idCharset.randomElement() })
    }

    private static func encodeProtobuf(id: String, timestamp: UInt64) -> Data {
        var data = Data()
        let idBytes = Data(id.utf8)
        data.append(0x0A)
        data.append(contentsOf: encodeVarint(UInt64(idBytes.count)))
        data.append(idBytes)
        data.append(0x28)
        data.append(contentsOf: encodeVarint(timestamp))
        return data
    }

    private static func encodeVarint(_ value: UInt64) -> [UInt8] {
        var result: [UInt8] = []
        var v = value
        while v > 0x7F {
            result.append(UInt8(v & 0x7F) | 0x80)
            v >>= 7
        }
        result.append(UInt8(v & 0x7F))
        return result
    }
}
