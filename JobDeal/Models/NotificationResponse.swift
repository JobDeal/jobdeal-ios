// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct NotificationResponse: Codable {
    let isBookmarked: Bool
    let country: String
    let latitude: Double
    let welcomeDescription: String
    let isUnderbidderListed: Bool
    let createdAt: String
    let applicantCount, price: Int
    let isBoost: Bool
    let property: JSONNull?
    let currency: String
    let isApplied: Bool
    let id: Int
    let isSpeedy: Bool
    let longitude: Double
    let isChoosed: Bool
    let images: [Image]
    let address, expireAt: String
    let isListed: Bool
    let mainImage: String
    let name: String
    let bidCount: Int
    let isExpired: Bool
    let categoryID, status: Int

    enum CodingKeys: String, CodingKey {
        case isBookmarked, country, latitude
        case welcomeDescription = "description"
        case isUnderbidderListed, createdAt, applicantCount, price, isBoost, property, currency, isApplied, id, isSpeedy, longitude, isChoosed, images, address, expireAt, isListed, mainImage, name, bidCount, isExpired
        case categoryID = "categoryId"
        case status
    }
}

// MARK: - Image
struct Image: Codable {
    let fullURL: String
    let id, position: Int

    enum CodingKeys: String, CodingKey {
        case fullURL = "fullUrl"
        case id, position
    }
}



// MARK: - Rate
struct Rate: Codable {
    let countBuyer, avgBuyer, countDoer, avgDoer: Int
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
