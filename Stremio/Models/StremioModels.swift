import Foundation

// MARK: - Stremio Addon Protocol Models

struct AddonManifest: Codable {
    let id: String
    let version: String
    let name: String
    let description: String?
    let catalogs: [CatalogDescriptor]?
    let resources: [ResourceItem]?
    let types: [String]?
    let idPrefixes: [String]?
}

enum ResourceItem: Codable {
    case string(String)
    case object(ResourceDescriptor)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else {
            self = .object(try container.decode(ResourceDescriptor.self))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let str): try container.encode(str)
        case .object(let obj): try container.encode(obj)
        }
    }
}

struct ResourceDescriptor: Codable {
    let name: String
    let types: [String]?
    let idPrefixes: [String]?
}

struct CatalogDescriptor: Codable, Identifiable {
    var id: String { "\(type)_\(catalogId)" }
    let type: String
    let catalogId: String
    let name: String?
    let extra: [ExtraDescriptor]?

    enum CodingKeys: String, CodingKey {
        case type
        case catalogId = "id"
        case name
        case extra
    }
}

struct ExtraDescriptor: Codable {
    let name: String
    let isRequired: Bool?
    let options: [String]?
}

struct MetaPreview: Codable, Identifiable {
    let id: String
    let type: String
    let name: String
    let poster: String?
    let posterShape: String?
    let description: String?
    let releaseInfo: String?
    let imdbRating: String?
    let year: Int?
    let genres: [String]?

    var displayYear: String {
        if let releaseInfo = releaseInfo { return releaseInfo }
        if let year = year { return "\(year)" }
        return ""
    }
}

struct CatalogResponse: Codable {
    let metas: [MetaPreview]?
}

struct MetaDetail: Codable, Identifiable {
    let id: String
    let type: String
    let name: String
    let poster: String?
    let background: String?
    let description: String?
    let releaseInfo: String?
    let imdbRating: String?
    let year: Int?
    let genres: [String]?
    let cast: [String]?
    let director: [String]?
    let runtime: String?
    let videos: [Video]?
    let logo: String?
}

struct MetaResponse: Codable {
    let meta: MetaDetail?
}

struct Video: Codable, Identifiable {
    let id: String
    let title: String?
    let season: Int?
    let episode: Int?
    let released: String?
    let overview: String?
    let thumbnail: String?

    var displayTitle: String {
        if let season = season, let episode = episode {
            let epTitle = title ?? ""
            return "S\(String(format: "%02d", season))E\(String(format: "%02d", episode))\(epTitle.isEmpty ? "" : " - \(epTitle)")"
        }
        return title ?? id
    }
}

struct Stream: Codable, Identifiable {
    var id: String { url ?? infoHash ?? name ?? UUID().uuidString }
    let name: String?
    let title: String?
    let url: String?
    let infoHash: String?
    let fileIdx: Int?
    let behaviorHints: BehaviorHints?
    let description: String?

    var displayName: String {
        name ?? "Stream"
    }

    var displayTitle: String {
        if let title = title { return title }
        if let description = description { return description }
        return ""
    }

    var isDebridLink: Bool {
        if let url = url {
            return url.contains("magnet:") || url.contains(".torrent")
        }
        return infoHash != nil
    }

    var magnetLink: String? {
        if let url = url, url.hasPrefix("magnet:") { return url }
        if let hash = infoHash {
            return "magnet:?xt=urn:btih:\(hash)"
        }
        return nil
    }
}

struct BehaviorHints: Codable {
    let bingeGroup: String?
    let notWebReady: Bool?
    let proxyHeaders: ProxyHeaders?
    let filename: String?
}

struct ProxyHeaders: Codable {
    let request: [String: String]?
    let response: [String: String]?
}

struct StreamResponse: Codable {
    let streams: [Stream]?
}
