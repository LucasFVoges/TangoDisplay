import Foundation
import TangoDisplayCore

// MARK: - Player choice

enum MusicPlayerChoice: String, CaseIterable, Identifiable {
    case musicApp = "musicApp"
    case swinsian = "swinsian"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .musicApp: return "Music.app"
        case .swinsian: return "Swinsian"
        }
    }
}

// MARK: - Protocol

/// Abstracts polling/push-based music player monitoring.
/// All callbacks must be delivered on the main queue.
protocol MusicPlayerSource: AnyObject {
    var onTrackUpdate: ((Track?, PlayerState) -> Void)? { get set }
    var onPlaylistUpdate: ((tracks: [Track], currentIndex: Int)?) -> Void { get set }
    var onWatchdogChanged: ((Bool) -> Void)? { get set }
    func start()
    func stop()
    func pollNow()
    func triggerPlaylistFetch()
}
