import SwiftUI
import TangoDisplayCore

struct PlayingView: View {
    let state: DisplayState
    let profile: AppearanceProfile
    let isLastTandaActive: Bool
    @ObservedObject var settings: AppSettings

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            ForEach(profile.danceItemOrder, id: \.self) { item in
                switch item {
                case .genre:
                    if profile.showGenreDance, let genre = state.currentTrack?.genre, !genre.isEmpty {
                        Text(settings.displayLabel(for: genre).uppercased())
                            .font(profile.genreFont)
                            .foregroundColor(profile.genreSwiftUIColor)
                            .multilineTextAlignment(.center)
                    }
                case .artist:
                    if profile.showArtistDance, let artist = state.currentTrack?.artist, !artist.isEmpty {
                        let displayArtist = settings.transform(artist, for: .artist)
                        Text(displayArtist)
                            .font(profile.artistFont)
                            .foregroundColor(profile.artistSwiftUIColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(Self.dynamicLineLimit(displayArtist))
                            .minimumScaleFactor(0.5)
                    }
                case .year:
                    if profile.showYearDance, let year = state.currentTrack?.year {
                        let displayYear = settings.transform(String(year), for: .year)
                        if !displayYear.isEmpty {
                            Text(displayYear)
                                .font(profile.yearFont)
                                .foregroundColor(profile.yearSwiftUIColor)
                                .multilineTextAlignment(.center)
                        }
                    }
                case .title:
                    if profile.showTitleDance, let title = state.currentTrack?.title, !title.isEmpty {
                        let displayTitle = settings.transform(title, for: .title)
                        Text(displayTitle)
                            .font(profile.titleFont)
                            .foregroundColor(profile.titleSwiftUIColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(Self.dynamicLineLimit(displayTitle))
                            .minimumScaleFactor(0.5)
                    }
                case .singer:
                    if profile.showSingerDance,
                       let rawSinger = state.currentTrack.flatMap({ profile.singerValue(from: $0) }),
                       !rawSinger.isEmpty {
                        let singerField: TrackInfoField = {
                            switch profile.singerSource {
                            case .albumArtist: return .albumArtist
                            case .comments:    return .comments
                            case .grouping:    return .grouping
                            }
                        }()
                        let singer = settings.transform(rawSinger, for: singerField)
                        if !singer.isEmpty {
                            Text(singer)
                                .font(profile.singerFont)
                                .foregroundColor(profile.singerSwiftUIColor)
                                .multilineTextAlignment(.center)
                                .lineLimit(Self.dynamicLineLimit(singer))
                                .minimumScaleFactor(0.5)
                        }
                    }
                case .lastTandaLabel:
                    if profile.showLastTandaLabel, isLastTandaActive, !settings.lastTandaLabel.isEmpty {
                        Text(settings.lastTandaLabel.uppercased())
                            .font(profile.lastTandaLabelFont)
                            .foregroundColor(profile.lastTandaLabelSwiftUIColor)
                            .multilineTextAlignment(.center)
                    }
                case .trackCounter:
                    if settings.showTrackCounter,
                       settings.trackCounterPosition == .centre,
                       let pos = state.tandaPosition {
                        Text(pos.label)
                            .font(profile.trackCounterFont)
                            .foregroundColor(profile.trackCounterSwiftUIColor)
                            .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 1)
                            .multilineTextAlignment(.center)
                    }
                case .cortinaLabel, .cortinaArtist, .cortinaTitle, .nextUpLabel:
                    EmptyView()
                }
            }

            Spacer()
        }
        .padding(.horizontal, 60)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    static func dynamicLineLimit(_ s: String) -> Int {
        min(4, max(2, s.components(separatedBy: "\n").count))
    }
}
