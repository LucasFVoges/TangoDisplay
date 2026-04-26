import SwiftUI
import TangoDisplayCore

extension Color {
    /// Parses "#RRGGBB" or "#RRGGBBAA" hex strings.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r, g, b, a: Double
        switch hex.count {
        case 6:
            r = Double((rgb >> 16) & 0xFF) / 255
            g = Double((rgb >> 8)  & 0xFF) / 255
            b = Double( rgb        & 0xFF) / 255
            a = 1.0
        case 8:
            r = Double((rgb >> 24) & 0xFF) / 255
            g = Double((rgb >> 16) & 0xFF) / 255
            b = Double((rgb >> 8)  & 0xFF) / 255
            a = Double( rgb        & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0; a = 1
        }
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

extension AppearanceProfile {
    var backgroundSwiftUIColor: Color    { Color(hex: backgroundColor) }
    var titleSwiftUIColor: Color         { Color(hex: titleColor) }
    var artistSwiftUIColor: Color        { Color(hex: artistColor) }
    var genreSwiftUIColor: Color         { Color(hex: genreColor) }
    var yearSwiftUIColor: Color          { Color(hex: yearColor) }
    var trackCounterSwiftUIColor: Color  { Color(hex: trackCounterColor) }

    func font(name: String, size: Double, bold: Bool, italic: Bool) -> Font {
        let weight: Font.Weight = bold ? .bold : .regular
        var f: Font
        if name == "System" || name.isEmpty {
            f = .system(size: size, weight: weight, design: .default)
        } else {
            f = .custom(name, size: size).weight(weight)
        }
        return italic ? f.italic() : f
    }

    var titleFont: Font  { font(name: titleFontName,  size: titleFontSize,  bold: titleFontBold,  italic: titleFontItalic) }
    var artistFont: Font { font(name: artistFontName, size: artistFontSize, bold: artistFontBold, italic: artistFontItalic) }
    var genreFont: Font  { font(name: genreFontName,  size: genreFontSize,  bold: genreFontBold,  italic: genreFontItalic) }
    var yearFont: Font   { font(name: yearFontName,   size: yearFontSize,   bold: yearFontBold,   italic: yearFontItalic) }
}
