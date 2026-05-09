import Foundation

public struct CortinaDetector {
    public var useAllowlist: Bool
    public var allowlistGenres: Set<String>         // pre-lowercased cortina genres
    public var useDenylist: Bool
    public var denylistGenres: Set<String>          // pre-lowercased dance genres (inverted logic)
    public var denylistPartialGenres: Set<String>   // pre-lowercased genres that also use substring matching

    public init(useAllowlist: Bool, allowlistGenres: Set<String>,
                useDenylist: Bool, denylistGenres: Set<String>,
                denylistPartialGenres: Set<String> = []) {
        self.useAllowlist = useAllowlist
        self.allowlistGenres = allowlistGenres
        self.useDenylist = useDenylist
        self.denylistGenres = denylistGenres
        self.denylistPartialGenres = denylistPartialGenres
    }

    /// Returns true if the genre indicates this track is a cortina.
    /// Empty genre returns true under denylist rule (not in dance-genres set).
    public func isCortina(genre: String) -> Bool {
        let g = genre.trimmingCharacters(in: .whitespaces).lowercased()
        if useAllowlist && allowlistGenres.contains(g) { return true }
        if useDenylist {
            let exactMatch = denylistGenres.contains(g) || denylistPartialGenres.contains(g)
            let partialMatch = denylistPartialGenres.contains { g.hasPrefix($0 + " ") || g.contains(" " + $0) }
            if !(exactMatch || partialMatch) { return true }
        }
        return false
    }
}
