import SwiftUI
import AVKit

struct StreamListView: View {
    let type: String
    let videoId: String
    let title: String
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var streams: [Stream] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var resolvingStreamId: String?
    @State private var playerURL: URL?
    @State private var showPlayer = false

    private let stremioService = StremioService()
    private let debridService = RealDebridService()

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Chargement des sources...")
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
                    .padding()
                } else if streams.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "film.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Aucune source disponible")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    streamList
                }
            }
            .navigationTitle("Sources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .task { await loadStreams() }
            .fullScreenCover(isPresented: $showPlayer) {
                if let url = playerURL {
                    VideoPlayerView(url: url, title: title)
                }
            }
        }
    }

    private var streamList: some View {
        List {
            ForEach(streams) { stream in
                Button {
                    Task { await resolveAndPlay(stream) }
                } label: {
                    streamRow(stream)
                }
                .disabled(resolvingStreamId != nil)
            }
        }
        .listStyle(.insetGrouped)
    }

    private func streamRow(_ stream: Stream) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(stream.displayName)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)

                if !stream.displayTitle.isEmpty {
                    Text(stream.displayTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }

            Spacer()

            if resolvingStreamId == stream.id {
                ProgressView()
            } else {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.purple)
            }
        }
        .padding(.vertical, 4)
    }

    private func loadStreams() async {
        do {
            streams = try await stremioService.fetchStreams(
                baseURL: settings.normalizedAddonURL,
                type: type,
                id: videoId
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func resolveAndPlay(_ stream: Stream) async {
        resolvingStreamId = stream.id

        do {
            let url = try await debridService.resolveStream(
                apiKey: settings.realDebridAPIKey,
                stream: stream
            )
            playerURL = url
            showPlayer = true
        } catch {
            errorMessage = error.localizedDescription
        }

        resolvingStreamId = nil
    }
}
