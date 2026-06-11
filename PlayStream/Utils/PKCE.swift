import Foundation
import CryptoKit

struct PKCE {
    let verifier: String
    let challenge: String
    
    init() {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        self.verifier = Data(bytes).base64URLEncodedString()
        
        guard let data = self.verifier.data(using: .utf8) else {
            fatalError("Failed to convert verifier to data")
        }
        let hash = SHA256.hash(data: data)
        self.challenge = Data(hash).base64URLEncodedString()
    }
}

extension Data {
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
