import Foundation

class PlaybackProgressManager {
    static let shared = PlaybackProgressManager()
    private let defaults = UserDefaults.standard
    private let keyPrefix = "playback_progress_"
    
    func saveProgress(for videoId: String, timeInSeconds: Double) {
        // Only save if progress is greater than 5 seconds to avoid saving accidental clicks
        if timeInSeconds > 5.0 {
            defaults.set(timeInSeconds, forKey: keyPrefix + videoId)
        }
    }
    
    func getProgress(for videoId: String) -> Double {
        return defaults.double(forKey: keyPrefix + videoId)
    }
    
    func clearProgress(for videoId: String) {
        defaults.removeObject(forKey: keyPrefix + videoId)
    }
}
