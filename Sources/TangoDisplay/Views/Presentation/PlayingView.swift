import SwiftUI
import TangoDisplayCore

struct PlayingView: View {
    let state: DisplayState
    let profile: AppearanceProfile

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            ForEach(profile.danceItemOrder, id: \.self) { item in
                switch item {
                case .genre:
                    if profile.showGenreDance, let genre = state.currentTrack?.genre, !genre.isEmpty {
                        Text(genre.uppercased())
                            .font(profile.genreFont)
                            .foregroundColor(profile.genreSwiftUIColor)
                            .multilineTextAlignment(.center)
                    }
                case .artist:
                    if profile.showArtistDance, let artist = state.currentTrack?.artist, !artist.isEmpty {
                        Text(artist)
                            .font(profile.artistFont)
                            .foregroundColor(profile.artistSwiftUIColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                    }
                case .year:
                    if profile.showYearDance, let year = state.currentTrack?.year {
                        Text(String(year))
                            .font(profile.yearFont)
                            .foregroundColor(profile.yearSwiftUIColor)
                            .multilineTextAlignment(.center)
                    }
                case .title:
                    if profile.showTitleDance, let title = state.currentTrack?.title, !title.isEmpty {
                        Text(title)
                            .font(profile.titleFont)
                            .foregroundColor(profile.titleSwiftUIColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                    }
                case .singer:
                    if profile.showSingerDance,
                       let singer = state.currentTrack.flatMap({ profile.singerValue(from: $0) }),
                       !singer.isEmpty {
                        Text(singer)
                            .font(profile.singerFont)
                            .foregroundColor(profile.singerSwiftUIColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
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
}
