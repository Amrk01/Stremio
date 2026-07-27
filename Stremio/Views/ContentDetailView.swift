import SwiftUI

struct ContentDetailView: View {
    let meta: MetaPreview
    @EnvironmentObject var settings: AppSettings
    @State private var detail: MetaDetail?
    @State private var isLoading = true
    @State private var showStreams = false
    @State private var selectedVideoId: String?

    private let stremioService = StremioService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                infoSection
                if let detail = detail {
                    if let videos = detail.videos, !videos.isEmpty, meta.type == "series" {
                        episodeSection(videos)
                    } else {
                        playButton(videoId: meta.id)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadDetail() }
        .sheet(isPresented: $showStreams) {
            if let videoId = selectedVideoId {
                StreamListView(type: meta.type, videoId: videoId, title: meta.name)
            }
        }
    }

    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            if let bg = detail?.background ?? meta.poster, let url = URL(string: bg) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                }
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color(.systemBackground)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
            }

            HStack(alignment: .bottom, spacing: 16) {
                if let poster = meta.poster, let url = URL(string: poster) {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(radius: 8)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 150)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(meta.name)
                        .font(.title2.bold())
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        if !meta.displayYear.isEmpty {
                            Text(meta.displayYear)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let rating = meta.imdbRating ?? detail?.imdbRating {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundStyle(.yellow)
                                Text(rating)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let genres = detail?.genres ?? meta.genres, !genres.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(genres, id: \.self) { genre in
                            Text(genre)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.15))
                                .foregroundStyle(.purple)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            if let description = detail?.description ?? meta.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(6)
            }

            if let cast = detail?.cast, !cast.isEmpty {
                Text("Avec: \(cast.prefix(5).joined(separator: ", "))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    private func playButton(videoId: String) -> some View {
        Button {
            selectedVideoId = videoId
            showStreams = true
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Regarder")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal)
        .padding(.bottom)
    }

    private func episodeSection(_ videos: [Video]) -> some View {
        let seasons = Dictionary(grouping: videos) { $0.season ?? 0 }
        let sortedSeasons = seasons.keys.sorted()

        return VStack(alignment: .leading, spacing: 16) {
            Text("Épisodes")
                .font(.title3.bold())
                .padding(.horizontal)

            ForEach(sortedSeasons, id: \.self) { season in
                if season > 0 {
                    Text("Saison \(season)")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }

                ForEach(seasons[season] ?? [], id: \.id) { video in
                    Button {
                        selectedVideoId = video.id
                        showStreams = true
                    } label: {
                        episodeRow(video)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.bottom)
    }

    private func episodeRow(_ video: Video) -> some View {
        HStack(spacing: 12) {
            if let thumb = video.thumbnail, let url = URL(string: thumb) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 68)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 68)
                        .overlay(
                            Image(systemName: "play.fill")
                                .foregroundStyle(.secondary)
                        )
                }
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 68)
                    .overlay(
                        Image(systemName: "play.fill")
                            .foregroundStyle(.secondary)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(video.displayTitle)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                if let overview = video.overview {
                    Text(overview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    private func loadDetail() async {
        do {
            detail = try await stremioService.fetchMeta(
                baseURL: settings.normalizedAddonURL,
                type: meta.type,
                id: meta.id
            )
        } catch {}
        isLoading = false
    }
}
