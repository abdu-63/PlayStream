import SwiftUI

struct HomeView: View {
    @StateObject private var driveAPI = DriveAPIService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.darkBackground.edgesIgnoringSafeArea(.all)
                
                if driveAPI.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let error = driveAPI.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if driveAPI.videos.isEmpty {
                    Text("Aucune vidéo trouvée sur Google Drive.")
                        .foregroundColor(Color.theme.textSecondary)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 32) {
                            // First Section: Popular Films
                            HomeSectionView(title: "Popular Films", videos: driveAPI.videos)
                            
                            // Second Section: Featured
                            HomeSectionView(title: "Récemment Ajoutés", videos: driveAPI.videos.reversed())
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if driveAPI.videos.isEmpty {
                    driveAPI.fetchVideos()
                }
            }
        }
    }
}

struct HomeSectionView: View {
    let title: String
    let videos: [DriveVideo]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.text)
                    
                    Rectangle()
                        .fill(Color.theme.primary)
                        .frame(width: 40, height: 3)
                }
                
                Spacer()
                
                Button(action: {}) {
                    HStack {
                        Text("Tout afficher")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color.theme.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.theme.darkSurface)
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(videos) { video in
                        NavigationLink(destination: MediaDetailView(video: video)) {
                            MediaCardView(video: video)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
