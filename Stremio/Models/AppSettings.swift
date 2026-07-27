import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("addonURL") var addonURL: String = ""
    @AppStorage("realDebridAPIKey") var realDebridAPIKey: String = ""
    @AppStorage("preferredQuality") var preferredQuality: String = "1080p"

    var isConfigured: Bool {
        !addonURL.isEmpty && !realDebridAPIKey.isEmpty
    }

    var normalizedAddonURL: String {
        var url = addonURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if url.hasSuffix("/") { url = String(url.dropLast()) }
        if url.hasSuffix("/manifest.json") {
            url = String(url.dropLast("/manifest.json".count))
        }
        return url
    }
}
