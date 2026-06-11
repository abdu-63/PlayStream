import SwiftUI
import AVKit

struct PlayerView: UIViewControllerRepresentable {
    let videoId: String
    let url: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        controller.player = player
        
        // Load previous progress
        let savedTime = PlaybackProgressManager.shared.getProgress(for: videoId)
        if savedTime > 0 {
            let cmTime = CMTime(seconds: savedTime, preferredTimescale: 600)
            player.seek(to: cmTime)
        }
        
        // Add periodic time observer to save progress
        let interval = CMTime(seconds: 5.0, preferredTimescale: 600)
        let observer = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            PlaybackProgressManager.shared.saveProgress(for: videoId, timeInSeconds: time.seconds)
        }
        
        context.coordinator.timeObserver = observer
        context.coordinator.player = player
        
        player.play()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Not needed for simple playback
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: PlayerView
        var timeObserver: Any?
        var player: AVPlayer?
        
        init(_ parent: PlayerView) {
            self.parent = parent
        }
        
        deinit {
            if let observer = timeObserver {
                player?.removeTimeObserver(observer)
            }
        }
    }
}
