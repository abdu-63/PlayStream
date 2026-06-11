import Foundation
import AuthenticationServices
import SwiftUI
import Combine

class DriveAuthService: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = DriveAuthService()
    
    @Published var isAuthenticated = false
    @AppStorage("google_access_token") var accessToken: String = ""
    
    private let clientId = "463819093914-ua3bup7on36hh4n110kcgv5pop4jvuq0.apps.googleusercontent.com"
    private let redirectScheme = "com.googleusercontent.apps.463819093914-ua3bup7on36hh4n110kcgv5pop4jvuq0"
    private let redirectUri = "com.googleusercontent.apps.463819093914-ua3bup7on36hh4n110kcgv5pop4jvuq0:/oauth2redirect"
    
    private var authSession: ASWebAuthenticationSession?
    
    override init() {
        super.init()
        if !accessToken.isEmpty {
            isAuthenticated = true
        }
    }
    
    func signIn() {
        let pkce = PKCE()
        
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "https://www.googleapis.com/auth/drive.readonly"),
            URLQueryItem(name: "code_challenge", value: pkce.challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]
        
        guard let url = components.url else { return }
        
        authSession = ASWebAuthenticationSession(url: url, callbackURLScheme: redirectScheme) { [weak self] callbackURL, error in
            guard let self = self, let callbackURL = callbackURL, error == nil else {
                print("Auth Error: \(String(describing: error))")
                return
            }
            
            guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                  let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                return
            }
            
            self.exchangeCodeForToken(code: code, verifier: pkce.verifier)
        }
        
        authSession?.presentationContextProvider = self
        authSession?.start()
    }
    
    private func exchangeCodeForToken(code: String, verifier: String) {
        let tokenUrl = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: tokenUrl)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = [
            "client_id": clientId,
            "code": code,
            "code_verifier": verifier,
            "redirect_uri": redirectUri,
            "grant_type": "authorization_code"
        ]
        
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        let bodyString = bodyParams.map { key, value in
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? key
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? value
            return "\(encodedKey)=\(encodedValue)"
        }.joined(separator: "&")
        
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = json["access_token"] as? String {
                DispatchQueue.main.async {
                    self.accessToken = token
                    self.isAuthenticated = true
                }
            }
        }.resume()
    }
    
    func signOut() {
        accessToken = ""
        isAuthenticated = false
    }
    
    // MARK: - ASWebAuthenticationPresentationContextProviding
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
}
