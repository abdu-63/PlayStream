import SwiftUI

struct HeroHeaderView: View {
    let video: DriveVideo
    let playAction: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Image
            if let urlString = video.highResThumbnailUrl?.absoluteString, let url = URL(string: urlString) {
                GeometryReader { geometry in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Color.theme.darkSurface
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Color.theme.darkSurface
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: geometry.size.width, height: 500)
                    .clipped()
                }
                .frame(height: 500)
            } else {
                Color.theme.darkSurface.frame(height: 500)
            }
            
            // Gradient Overlay
            LinearGradient.heroFade
                .frame(height: 500)
            
            // Content
            VStack(spacing: 16) {
                Text(video.name.replacingOccurrences(of: ".mp4", with: "").replacingOccurrences(of: ".mkv", with: ""))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.text)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Biography • Drama • History")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.textSecondary)
                
                HStack(spacing: 16) {
                    Button(action: playAction) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Play")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(25)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "bookmark")
                            Text("Enregistrer")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.theme.darkSurface)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
