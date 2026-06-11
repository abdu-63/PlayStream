import Foundation

struct DriveFileListResponse: Codable {
    let files: [DriveVideo]
}

struct DriveVideo: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let mimeType: String
    let thumbnailLink: String?
    let videoMediaMetadata: VideoMetadata?
    
    // Helper to get duration string
    var durationString: String {
        guard let durationMillisString = videoMediaMetadata?.durationMillis,
              let durationMillis = Double(durationMillisString) else {
            return "Inconnu"
        }
        let totalSeconds = Int(durationMillis / 1000)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // Helper for high-res thumbnail
    var highResThumbnailUrl: URL? {
        guard let link = thumbnailLink else { return nil }
        // Drive thumbnails end with =s220, replace with higher resolution
        let highResLink = link.replacingOccurrences(of: "=s220", with: "=s1080")
        return URL(string: highResLink)
    }
    
    // Dummy variables for UI
    var director: String { "Inconnu" }
    var year: String { "2024" }
}

struct VideoMetadata: Codable, Hashable {
    let durationMillis: String?
}
