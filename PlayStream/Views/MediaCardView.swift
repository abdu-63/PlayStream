import SwiftUI

struct MediaCardView: View {
    let video: DriveVideo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Color.theme.darkSurface
                
                if let urlString = video.highResThumbnailUrl?.absoluteString, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image(systemName: "film")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "film")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 140, height: 210)
            .cornerRadius(12)
            .clipped()
            
            Text(video.name.replacingOccurrences(of: ".mp4", with: "").replacingOccurrences(of: ".mkv", with: ""))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.text)
                .lineLimit(1)
            
            Text(video.year)
                .font(.caption)
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(width: 140)
    }
}
