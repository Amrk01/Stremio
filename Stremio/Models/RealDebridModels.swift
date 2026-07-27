import Foundation

struct RealDebridUnrestrictResponse: Codable {
    let id: String
    let filename: String
    let mimeType: String?
    let filesize: Int?
    let link: String
    let host: String?
    let chunks: Int?
    let download: String
    let streamable: Int?
}

struct RealDebridAddMagnetResponse: Codable {
    let id: String
    let uri: String
}

struct RealDebridTorrentInfo: Codable {
    let id: String
    let filename: String?
    let status: String
    let links: [String]?
    let files: [RealDebridFile]?

    var isReady: Bool { status == "downloaded" }
}

struct RealDebridFile: Codable {
    let id: Int
    let path: String
    let bytes: Int
    let selected: Int?
}

struct RealDebridError: Codable {
    let error: String?
    let errorCode: Int?

    enum CodingKeys: String, CodingKey {
        case error
        case errorCode = "error_code"
    }
}
