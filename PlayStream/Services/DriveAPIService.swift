import Foundation
import Combine
import SwiftUI

class DriveAPIService: ObservableObject {
    static let shared = DriveAPIService()
    
    @Published var videos: [DriveVideo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchVideos() {
        let token = DriveAuthService.shared.accessToken
        guard !token.isEmpty else {
            self.errorMessage = "Non authentifié"
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        // Fetch files where mimeType contains 'video'
        var components = URLComponents(string: "https://www.googleapis.com/drive/v3/files")!
        components.queryItems = [
            URLQueryItem(name: "q", value: "mimeType contains 'video' and trashed = false"),
            URLQueryItem(name: "fields", value: "files(id,name,mimeType,thumbnailLink,videoMediaMetadata)"),
            URLQueryItem(name: "pageSize", value: "50"),
            URLQueryItem(name: "orderBy", value: "createdTime desc")
        ]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                do {
                    let decoded = try JSONDecoder().decode(DriveFileListResponse.self, from: data)
                    self.videos = decoded.files
                } catch {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    // Generates the URL for streaming the video using AVPlayer
    func streamUrl(for videoId: String) -> URL? {
        let token = DriveAuthService.shared.accessToken
        guard !token.isEmpty else { return nil }
        
        // Passing the access_token in the URL allows AVPlayer to stream it without custom HTTP headers
        let urlString = "https://www.googleapis.com/drive/v3/files/\(videoId)?alt=media&access_token=\(token)"
        return URL(string: urlString)
    }
    
    // Resolves the redirect URL asynchronously to stream directly from googleusercontent.com
    func fetchDirectStreamURL(for videoId: String) async throws -> URL {
        let token = DriveAuthService.shared.accessToken
        guard !token.isEmpty else {
            throw NSError(domain: "DriveAPIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Non authentifié"])
        }
        
        let urlString = "https://www.googleapis.com/drive/v3/files/\(videoId)?alt=media"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "DriveAPIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL de fichier invalide"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let resolver = RedirectResolver()
        let session = URLSession(configuration: .default, delegate: resolver, delegateQueue: nil)
        defer {
            session.invalidateAndCancel()
        }
        
        let (_, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if (300...399).contains(httpResponse.statusCode), let redirectURL = resolver.redirectURL {
                return redirectURL
            }
            if httpResponse.statusCode == 200 {
                let fallbackString = "https://www.googleapis.com/drive/v3/files/\(videoId)?alt=media&access_token=\(token)"
                if let fallbackURL = URL(string: fallbackString) {
                    return fallbackURL
                }
            }
            throw NSError(domain: "DriveAPIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Erreur serveur (\(httpResponse.statusCode))"])
        }
        throw NSError(domain: "DriveAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Réponse serveur invalide"])
    }
}

private class RedirectResolver: NSObject, URLSessionTaskDelegate {
    var redirectURL: URL?
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let location = response.allHeaderFields["Location"] as? String, let url = URL(string: location) {
            self.redirectURL = url
        } else {
            self.redirectURL = newRequest.url
        }
        completionHandler(nil)
    }
}
