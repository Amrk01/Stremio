import SwiftUI

struct SearchView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var query = ""
    @State private var results: [MetaPreview] = []
    @State private var isSearching = false
    @State private var hasSearched = false
    @State private var manifest: AddonManifest?

    private let stremioService = StremioService()

    private let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 150), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            VStack {
                if isSearching {
                    ProgressView("Recherche en cours...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if results.isEmpty && hasSearched {
                    emptyState
                } else if results.isEmpty {
                    initialState
                } else {
                    resultGrid
                }
            }
            .navigationTitle("Recherche")
            .searchable(text: $query, prompt: "Film, série...")
            .onSubmit(of: .search) {
                Task { await search() }
            }
            .task { await loadManifest() }
        }
    }

    private var initialState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Recherchez un film ou une série")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "film.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Aucun résultat pour \"\(query)\"")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var resultGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(results) { item in
                    NavigationLink {
                        ContentDetailView(meta: item)
                    } label: {
                        PosterCard(meta: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    private func loadManifest() async {
        do {
            manifest = try await stremioService.fetchManifest(baseURL: settings.normalizedAddonURL)
        } catch {}
    }

    private func search() async {
        guard !query.isEmpty else { return }
        isSearching = true
        hasSearched = true
        results = []

        let searchableCatalogs = manifest?.catalogs?.filter { catalog in
            catalog.extra?.contains(where: { $0.name == "search" }) ?? false
        } ?? []

        if searchableCatalogs.isEmpty {
            if let catalogs = manifest?.catalogs {
                for catalog in catalogs.prefix(3) {
                    do {
                        let items = try await stremioService.searchCatalog(
                            baseURL: settings.normalizedAddonURL,
                            type: catalog.type,
                            catalogId: catalog.catalogId,
                            query: query
                        )
                        results.append(contentsOf: items)
                    } catch {}
                }
            }
        } else {
            for catalog in searchableCatalogs {
                do {
                    let items = try await stremioService.searchCatalog(
                        baseURL: settings.normalizedAddonURL,
                        type: catalog.type,
                        catalogId: catalog.catalogId,
                        query: query
                    )
                    results.append(contentsOf: items)
                } catch {}
            }
        }

        // Deduplicate by ID
        var seen = Set<String>()
        results = results.filter { seen.insert($0.id).inserted }
        isSearching = false
    }
}
