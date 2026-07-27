import Foundation

actor StremioService {
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }

    func fetchManifest(baseURL: String) async throws -> AddonManifest {
        let url = URL(string: "\(baseURL)/manifest.json")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(AddonManifest.self, from: data)
    }

    func fetchCatalog(baseURL: String, type: String, catalogId: String, extra: [String: String]? = nil) async throws -> [MetaPreview] {
        var path = "\(baseURL)/catalog/\(type)/\(catalogId)"
        if let extra = extra, !extra.isEmpty {
            let parts = extra.map { "\($0.key)=\($0.value)" }
            path += "/\(parts.joined(separator: "&"))"
        }
        path += ".json"

        guard let url = URL(string: path) else {
            throw StremioError.invalidURL
        }

        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(CatalogResponse.self, from: data)
        return response.metas ?? []
    }

    func searchCatalog(baseURL: String, type: String, catalogId: String, query: String) async throws -> [MetaPreview] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? query
        let path = "\(baseURL)/catalog/\(type)/\(catalogId)/search=\(encoded).json"

        guard let url = URL(string: path) else {
            throw StremioError.invalidURL
        }

        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(CatalogResponse.self, from: data)
        return response.metas ?? []
    }

    func fetchMeta(baseURL: String, type: String, id: String) async throws -> MetaDetail {
        let path = "\(baseURL)/meta/\(type)/\(id).json"
        guard let url = URL(string: path) else {
            throw StremioError.invalidURL
        }

        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(MetaResponse.self, from: data)
        guard let meta = response.meta else {
            throw StremioError.noResults
        }
        return meta
    }

    func fetchStreams(baseURL: String, type: String, id: String) async throws -> [Stream] {
        let path = "\(baseURL)/stream/\(type)/\(id).json"
        guard let url = URL(string: path) else {
            throw StremioError.invalidURL
        }

        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(StreamResponse.self, from: data)
        return response.streams ?? []
    }
}

enum StremioError: LocalizedError {
    case invalidURL
    case noResults
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL invalide"
        case .noResults: return "Aucun résultat"
        case .networkError(let msg): return msg
        }
    }
}
