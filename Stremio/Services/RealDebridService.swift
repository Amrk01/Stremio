import Foundation

actor RealDebridService {
    private let session: URLSession
    private let baseURL = "https://api.real-debrid.com/rest/1.0"

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120
        self.session = URLSession(configuration: config)
    }

    private func authorizedRequest(url: URL, apiKey: String, method: String = "GET", body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        if let body = body {
            request.httpBody = body
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        return request
    }

    func unrestrictLink(apiKey: String, link: String) async throws -> RealDebridUnrestrictResponse {
        let url = URL(string: "\(baseURL)/unrestrict/link")!
        let body = "link=\(link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? link)"
        let request = authorizedRequest(url: url, apiKey: apiKey, method: "POST", body: body.data(using: .utf8))

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            if let error = try? JSONDecoder().decode(RealDebridError.self, from: data) {
                throw RealDebridServiceError.apiError(error.error ?? "Erreur inconnue")
            }
            throw RealDebridServiceError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(RealDebridUnrestrictResponse.self, from: data)
    }

    func addMagnet(apiKey: String, magnet: String) async throws -> RealDebridAddMagnetResponse {
        let url = URL(string: "\(baseURL)/torrents/addMagnet")!
        let body = "magnet=\(magnet.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? magnet)"
        let request = authorizedRequest(url: url, apiKey: apiKey, method: "POST", body: body.data(using: .utf8))

        let (data, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 201 {
            if let error = try? JSONDecoder().decode(RealDebridError.self, from: data) {
                throw RealDebridServiceError.apiError(error.error ?? "Erreur inconnue")
            }
            throw RealDebridServiceError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(RealDebridAddMagnetResponse.self, from: data)
    }

    func getTorrentInfo(apiKey: String, torrentId: String) async throws -> RealDebridTorrentInfo {
        let url = URL(string: "\(baseURL)/torrents/info/\(torrentId)")!
        let request = authorizedRequest(url: url, apiKey: apiKey)
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(RealDebridTorrentInfo.self, from: data)
    }

    func selectFiles(apiKey: String, torrentId: String, fileIds: String = "all") async throws {
        let url = URL(string: "\(baseURL)/torrents/selectFiles/\(torrentId)")!
        let body = "files=\(fileIds)"
        let request = authorizedRequest(url: url, apiKey: apiKey, method: "POST", body: body.data(using: .utf8))
        let (_, response) = try await session.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 204 && httpResponse.statusCode != 200 {
            throw RealDebridServiceError.httpError(httpResponse.statusCode)
        }
    }

    func resolveStream(apiKey: String, stream: Stream) async throws -> URL {
        if let urlString = stream.url, !stream.isDebridLink {
            guard let url = URL(string: urlString) else {
                throw RealDebridServiceError.invalidURL
            }
            return url
        }

        if let urlString = stream.url, urlString.hasPrefix("http") {
            let result = try await unrestrictLink(apiKey: apiKey, link: urlString)
            guard let downloadURL = URL(string: result.download) else {
                throw RealDebridServiceError.invalidURL
            }
            return downloadURL
        }

        guard let magnet = stream.magnetLink else {
            throw RealDebridServiceError.noMagnetLink
        }

        let addResult = try await addMagnet(apiKey: apiKey, magnet: magnet)

        try await selectFiles(apiKey: apiKey, torrentId: addResult.id)

        var attempts = 0
        while attempts < 30 {
            let info = try await getTorrentInfo(apiKey: apiKey, torrentId: addResult.id)

            if info.isReady, let links = info.links, !links.isEmpty {
                let linkToUse: String
                if let fileIdx = stream.fileIdx, fileIdx < links.count {
                    linkToUse = links[fileIdx]
                } else {
                    linkToUse = links[0]
                }

                let unrestricted = try await unrestrictLink(apiKey: apiKey, link: linkToUse)
                guard let url = URL(string: unrestricted.download) else {
                    throw RealDebridServiceError.invalidURL
                }
                return url
            }

            try await Task.sleep(nanoseconds: 2_000_000_000)
            attempts += 1
        }

        throw RealDebridServiceError.timeout
    }
}

enum RealDebridServiceError: LocalizedError {
    case invalidURL
    case noMagnetLink
    case apiError(String)
    case httpError(Int)
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL invalide"
        case .noMagnetLink: return "Pas de lien magnet disponible"
        case .apiError(let msg): return "RealDebrid: \(msg)"
        case .httpError(let code): return "Erreur HTTP \(code)"
        case .timeout: return "Timeout - le torrent n'est pas prêt"
        }
    }
}
