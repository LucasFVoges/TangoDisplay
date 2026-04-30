import SwiftUI
import TangoDisplayCore

struct CortinaView: View {
    let state: DisplayState
    let profile: AppearanceProfile
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
                            Text(artist)
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
                            Text(title)
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

            if profile.showNextTrackDuringCortina, let next = state.nextTrack {
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
                            Text(settings.nextUpLabel)
                                .font(profile.nextUpLabelFont)
                                .tracking(4)
                                .foregroundColor(profile.nextUpLabelSwiftUIColor)
                        case .genre:
                            if profile.showGenreCortina, !next.genre.isEmpty {
                                Text(next.genre)
                                    .font(profile.genreFont)
                                    .foregroundColor(profile.genreSwiftUIColor)
                            }
                        case .artist:
                            if profile.showArtistCortina {
                                Text(next.artist)
                                    .font(profile.artistFont)
                                    .foregroundColor(profile.artistSwiftUIColor)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                                    .multilineTextAlignment(.center)
                            }
                        case .year:
                            if profile.showYearCortina, let year = next.year {
                                Text(String(year))
                                    .font(profile.yearFont)
                                    .foregroundColor(profile.yearSwiftUIColor)
                                    .multilineTextAlignment(.center)
                            }
                        case .title:
                            if profile.showTitleCortina, !next.title.isEmpty {
                                Text(next.title)
                                    .font(profile.titleFont)
                                    .foregroundColor(profile.titleSwiftUIColor)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                            }
                        case .singer:
                            if profile.showSingerCortina,
                               let singer = profile.singerValue(from: next), !singer.isEmpty {
                                Text(singer)
                                    .font(profile.singerFont)
                                    .foregroundColor(profile.singerSwiftUIColor)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
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
