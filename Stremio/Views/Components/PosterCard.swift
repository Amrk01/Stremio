import SwiftUI

struct PosterCard: View {
    let meta: MetaPreview

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            posterImage

            Text(meta.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if !meta.displayYear.isEmpty {
                Text(meta.displayYear)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 120)
    }

    private var posterImage: some View {
        Group {
            if let poster = meta.poster, let url = URL(string: poster) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    posterPlaceholder
                }
            } else {
                posterPlaceholder
            }
        }
        .frame(width: 120, height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var posterPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: "film")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(meta.name)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }
            )
    }
}
