import SwiftUI
import TangoDisplayCore

struct CortinaView: View {
    let state: DisplayState
    let profile: AppearanceProfile
    let isLastTandaActive: Bool
    @ObservedObject var settings: AppSettings

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Cortina-track section: CORTINA label always shown; artist/title gated by toggle
            VStack(spacing: 12) {
                ForEach(profile.cortinaTrackItemOrder, id: \.self) { item in
                    switch item {
                    case .cortinaLabel:
                        Text(settings.cortinaLabel)
                            .font(profile.cortinaLabelFont)
                            .tracking(12)
                            .foregroundColor(profile.cortinaLabelSwiftUIColor)
                            .multilineTextAlignment(.center)
                    case .cortinaArtist:
                        if profile.showCortinaTrackDuringCortina,
                           profile.showCortinaTrackArtist,
                           let artist = state.currentTrack?.artist, !artist.isEmpty {
                            Text(settings.transform(artist, for: .artist))
                                .font(profile.cortinaArtistFont)
                                .foregroundColor(profile.cortinaArtistSwiftUIColor)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                        }
                    case .cortinaTitle:
                        if profile.showCortinaTrackDuringCortina,
                           profile.showCortinaTrackTitle,
                           let title = state.currentTrack?.title, !title.isEmpty {
                            Text(settings.transform(title, for: .title))
                                .font(profile.cortinaTitleFont)
                                .foregroundColor(profile.cortinaTitleSwiftUIColor)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                        }
                    default:
                        EmptyView()
                    }
                }
            }

            let showComingUp = profile.showNextTrackDuringCortina && state.nextTrack != nil
            let showLastTanda = isLastTandaActive && profile.showLastTandaLabel && !settings.lastTandaLabel.isEmpty
            if showComingUp || showLastTanda {
                // Divider between cortina section and coming-up section
                Rectangle()
                    .fill(profile.genreSwiftUIColor.opacity(0.3))
                    .frame(width: 120, height: 1)
                    .padding(.vertical, 8)

                // Coming-up section
                VStack(spacing: 12) {
                    ForEach(profile.cortinaItemOrder, id: \.self) { item in
                        switch item {
                        case .nextUpLabel:
                            if showComingUp {
                                Text(settings.nextUpLabel)
                                    .font(profile.nextUpLabelFont)
                                    .tracking(4)
                                    .foregroundColor(profile.nextUpLabelSwiftUIColor)
                            }
                        case .genre:
                            if showComingUp, let next = state.nextTrack,
                               profile.showGenreCortina, !next.genre.isEmpty {
                                Text(settings.displayLabel(for: next.genre))
                                    .font(profile.genreFont)
                                    .foregroundColor(profile.genreSwiftUIColor)
                            }
                        case .artist:
                            if showComingUp, let next = state.nextTrack, profile.showArtistCortina {
                                Text(settings.transform(next.artist, for: .artist))
                                    .font(profile.artistFont)
                                    .foregroundColor(profile.artistSwiftUIColor)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                            }
                        case .year:
                            if showComingUp, let next = state.nextTrack,
                               profile.showYearCortina, let year = next.year {
                                let displayYear = settings.transform(String(year), for: .year)
                                if !displayYear.isEmpty {
                                    Text(displayYear)
                                        .font(profile.yearFont)
                                        .foregroundColor(profile.yearSwiftUIColor)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        case .title:
                            if showComingUp, let next = state.nextTrack,
                               profile.showTitleCortina, !next.title.isEmpty {
                                Text(settings.transform(next.title, for: .title))
                                    .font(profile.titleFont)
                                    .foregroundColor(profile.titleSwiftUIColor)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                            }
                        case .singer:
                            if showComingUp, let next = state.nextTrack,
                               profile.showSingerCortina,
                               let rawSinger = profile.singerValue(from: next), !rawSinger.isEmpty {
                                let singerField: TrackInfoField = profile.singerSource == .albumArtist ? .albumArtist : .comments
                                let singer = settings.transform(rawSinger, for: singerField)
                                if !singer.isEmpty {
                                    Text(singer)
                                        .font(profile.singerFont)
                                        .foregroundColor(profile.singerSwiftUIColor)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.5)
                                }
                            }
                        case .lastTandaLabel:
                            if showLastTanda {
                                Text(settings.lastTandaLabel.uppercased())
                                    .font(profile.lastTandaLabelFont)
                                    .foregroundColor(profile.lastTandaLabelSwiftUIColor)
                                    .multilineTextAlignment(.center)
                            }
                        default:
                            EmptyView()
                        }
                    }
                }
                .padding(.horizontal, 60)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
