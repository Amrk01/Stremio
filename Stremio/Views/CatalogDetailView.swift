import SwiftUI

struct CatalogDetailView: View {
    let catalog: CatalogDescriptor
    @EnvironmentObject var settings: AppSettings
    @State private var items: [MetaPreview] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let stremioService = StremioService()

    private let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 150), spacing: 12)
    ]

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Chargement...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(items) { item in
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
        }
        .navigationTitle(catalog.name ?? catalog.catalogId)
        .task { await loadItems() }
    }

    private func loadItems() async {
        do {
            items = try await stremioService.fetchCatalog(
                baseURL: settings.normalizedAddonURL,
                type: catalog.type,
                catalogId: catalog.catalogId
            )
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
