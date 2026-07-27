import SwiftUI

struct CatalogView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var manifest: AddonManifest?
    @State private var catalogs: [String: [MetaPreview]] = [:]
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedCatalog: CatalogDescriptor?

    private let stremioService = StremioService()

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Chargement...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    errorView(error)
                } else if let manifest = manifest {
                    catalogList(manifest)
                }
            }
            .navigationTitle("Catalogue")
            .refreshable { await loadManifest() }
            .task { await loadManifest() }
        }
    }

    private func catalogList(_ manifest: AddonManifest) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                if let catalogDescriptors = manifest.catalogs {
                    ForEach(catalogDescriptors) { catalog in
                        catalogSection(catalog)
                    }
                }
            }
            .padding(.vertical)
        }
    }

    private func catalogSection(_ catalog: CatalogDescriptor) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(catalog.name ?? catalog.catalogId)
                    .font(.title3.bold())
                    .padding(.horizontal)

                Spacer()

                NavigationLink {
                    CatalogDetailView(catalog: catalog)
                } label: {
                    Text("Voir tout")
                        .font(.subheadline)
                        .foregroundStyle(.purple)
                }
                .padding(.horizontal)
            }

            if let items = catalogs[catalog.id], !items.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(items.prefix(20)) { item in
                            NavigationLink {
                                ContentDetailView(meta: item)
                            } label: {
                                PosterCard(meta: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                ProgressView()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .task {
                        await loadCatalog(catalog)
                    }
            }
        }
    }

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(error)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Réessayer") {
                Task { await loadManifest() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private func loadManifest() async {
        isLoading = true
        errorMessage = nil
        do {
            manifest = try await stremioService.fetchManifest(baseURL: settings.normalizedAddonURL)
            isLoading = false
        } catch {
            errorMessage = "Impossible de charger le manifest: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func loadCatalog(_ catalog: CatalogDescriptor) async {
        do {
            let items = try await stremioService.fetchCatalog(
                baseURL: settings.normalizedAddonURL,
                type: catalog.type,
                catalogId: catalog.catalogId
            )
            catalogs[catalog.id] = items
        } catch {
            catalogs[catalog.id] = []
        }
    }
}
