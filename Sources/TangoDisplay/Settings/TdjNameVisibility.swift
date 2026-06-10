import Foundation

enum TdjNameVisibility: String, CaseIterable, Identifiable {
    case playing
    case idlePaused
    case always

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .playing:    return "Any track playing"
        case .idlePaused: return "Idle / Paused"
        case .always:     return "Always"
        }
    }
}
