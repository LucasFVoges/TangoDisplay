import Foundation

public struct Track: Equatable, Hashable, Codable {
    public let title: String
    public let artist: String
    public let genre: String        // empty string when Music.app returns nothing
    public let persistentID: String // stable identity across polls
    public let year: Int?           // nil when Music.app returns 0 or nothing

    public init(title: String, artist: String, genre: String,
                persistentID: String, year: Int? = nil) {
        self.title = title
        self.artist = artist
        self.genre = genre
        self.persistentID = persistentID
        self.year = year
    }
}
