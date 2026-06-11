import SwiftUI

extension Color {
    static let theme = Theme()
}

struct Theme {
    let background = Color("BackgroundColor", bundle: nil) // We will provide a fallback
    let surface = Color("SurfaceColor", bundle: nil)
    let text = Color.white
    let textSecondary = Color.gray
    let primary = Color.blue
    let accent = Color.yellow
    
    // Fallback colors for simplicity without assets
    let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.07)
    let darkSurface = Color(red: 0.12, green: 0.12, blue: 0.14)
}

// Global gradient for headers
extension LinearGradient {
    static let heroFade = LinearGradient(
        gradient: Gradient(colors: [Color.clear, Color.theme.darkBackground]),
        startPoint: .top,
        endPoint: .bottom
    )
}
