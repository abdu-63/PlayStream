import SwiftUI

struct MediaDetailView: View {
    let video: DriveVideo
    @State private var isPlaying = false
    @State private var resolvedURL: URL?
    @State private var isLoadingStream = false
    @State private var streamError: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HeroHeaderView(video: video) {
                        startPlayback()
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // Quick Stats
                        HStack(spacing: 16) {
                            Text(video.year)
                                .fontWeight(.bold)
                            Text(video.durationString)
                                .fontWeight(.bold)
                            Text("PG-13")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(4)
                            Text("7.7")
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                        .foregroundColor(Color.theme.text)
                        
                        // Director Info
                        HStack {
                            Text("Director:")
                                .foregroundColor(Color.theme.textSecondary)
                            Text(video.director)
                                .foregroundColor(Color.theme.text)
                        }
                        
                        Text("L'histoire captivante de \(video.name.replacingOccurrences(of: ".mp4", with: "")), l'un des contenus les plus influents que le monde ait jamais connu. Un voyage extraordinaire depuis ses débuts jusqu'à la gloire mondiale.")
                            .foregroundColor(Color.theme.textSecondary)
                            .lineSpacing(4)
                        
                        Button(action: {}) {
                            HStack {
                                Text("Show More")
                                Image(systemName: "chevron.down")
                            }
                            .font(.subheadline)
                            .foregroundColor(Color.theme.textSecondary)
                        }
                        
                        // Cast Section
                        Text("Distribution")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.text)
                            .padding(.top, 8)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<4) { index in
                                    VStack {
                                        Circle()
                                            .fill(Color.theme.darkSurface)
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .foregroundColor(.gray)
                                                    .font(.largeTitle)
                                            )
                                        Text("Actor \(index + 1)")
                                            .font(.caption)
                                            .foregroundColor(Color.theme.text)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.theme.darkBackground.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            
            if isLoadingStream {
                ZStack {
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Préparation de la lecture...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(30)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
            }
        }
        .fullScreenCover(isPresented: $isPlaying) {
            if let url = resolvedURL {
                PlayerView(videoId: video.id, url: url)
                    .edgesIgnoringSafeArea(.all)
                    .background(Color.black)
            } else {
                Text("Impossible de charger la vidéo")
                    .foregroundColor(.white)
            }
        }
        .alert(isPresented: Binding<Bool>(
            get: { streamError != nil },
            set: { _ in streamError = nil }
        )) {
            Alert(
                title: Text("Erreur de lecture"),
                message: Text(streamError ?? "Une erreur inconnue est survenue"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func startPlayback() {
        isLoadingStream = true
        streamError = nil
        
        Task {
            do {
                let url = try await DriveAPIService.shared.fetchDirectStreamURL(for: video.id)
                await MainActor.run {
                    self.resolvedURL = url
                    self.isLoadingStream = false
                    self.isPlaying = true
                }
            } catch {
                await MainActor.run {
                    self.streamError = error.localizedDescription
                    self.isLoadingStream = false
                }
            }
        }
    }
}
