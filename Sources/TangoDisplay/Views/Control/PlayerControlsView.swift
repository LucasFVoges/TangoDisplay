import SwiftUI

struct PlayerControlsView: View {
    @ObservedObject var player: LocalPlayerSource
    @EnvironmentObject var appState: AppState
    var onScrollToCurrentTrack: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                LevelMeterView(meter: player.levelMeter)
                    .frame(maxHeight: .infinity)

                VStack(spacing: 10) {
                    trackInfo
                    transportButtons
                    fadeButtons
                }
                .frame(maxWidth: .infinity)

                artworkPanel
                    .frame(width: LevelMeterView.totalWidth)
                    .frame(maxHeight: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
            seekBar
            volumeRow
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .animation(.easeInOut(duration: 0.2), value: appState.currentArtwork != nil)
    }

    // MARK: - Artwork panel

    @ViewBuilder
    private var artworkPanel: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08)
            if let art = appState.currentArtwork {
                Image(nsImage: art)
                    .resizable()
                    .scaledToFill()
            } else if let url = Bundle.main.url(forResource: "SetlistLogo", withExtension: "png"),
                      let nsImage = NSImage(contentsOf: url) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Subviews

    private var trackInfo: some View {
        let track = appState.displayState.currentTrack
        return VStack(spacing: 3) {
            HStack(spacing: 8) {
                Text(track?.title ?? "No track loaded")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(track == nil ? .secondary : .primary)
                    .lineLimit(1)
                if track != nil,
                   appState.currentPlayerState == .playing || appState.currentPlayerState == .pauseArmed {
                    Button {
                        onScrollToCurrentTrack?()
                    } label: {
                        Image(systemName: "eye")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Scroll setlist to current track")
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            Text(track?.artist ?? " ")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var transportButtons: some View {
        HStack(spacing: 10) {
            Spacer()
            Button {
                switch appState.currentPlayerState {
                case .playing, .pauseArmed: appState.transportPause()
                case .paused, .stopped:     appState.transportPlay()
                }
            } label: {
                let (icon, color): (String, Color) = {
                    switch appState.currentPlayerState {
                    case .stopped:    return ("play.circle.fill",  ControlTheme.accent)
                    case .playing:    return ("stop.circle.fill",  ControlTheme.accent)
                    case .pauseArmed: return ("stop.circle.fill",  .red)
                    case .paused:     return ("play.circle.fill",  .orange)
                    }
                }()
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }

    private var seekBar: some View {
        VStack(spacing: 3) {
            GeometryReader { geo in
                let progress = player.duration > 0
                    ? player.elapsed / max(player.duration, 1)
                    : 0
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(nsColor: .separatorColor))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ControlTheme.accent)
                        .frame(width: geo.size.width * progress, height: 4)
                    let shouldShow = !appState.settings.markAsPlayedAfterCompletion
                        && player.duration > 0
                        && !player.isCurrentEntryMarkedAsPlayed
                    let fraction = min(1.0, Double(appState.settings.markAsPlayedAfterSeconds) / player.duration)
                    Rectangle()
                        .fill(ControlTheme.accent.opacity(0.7))
                        .frame(width: 2, height: 10)
                        .position(x: fraction * geo.size.width, y: geo.size.height / 2)
                        .opacity(shouldShow ? 1 : 0)
                    let autoFadeDelay: Double = {
                        guard appState.settings.autoFadeCortinasEnabled,
                              appState.displayState.mode == .cortina,
                              player.duration > 0 else { return -1 }
                        if appState.setlist.entries.first(where: { $0.id == player.currentEntryID })?.ignoresAutoFade == true { return -1 }
                        let fade = appState.settings.builtInFadeDuration
                        let play = appState.settings.cortinaPlayTime
                        let dur = player.duration
                        if dur > play + fade { return play }
                        if dur > fade        { return dur - fade }
                        return -1
                    }()
                    Rectangle()
                        .fill(Color.orange.opacity(0.85))
                        .frame(width: 2, height: 10)
                        .position(x: (autoFadeDelay / player.duration) * geo.size.width, y: geo.size.height / 2)
                        .opacity(autoFadeDelay >= 0 ? 1 : 0)
                }
                .allowsHitTesting(false)
            }
            .frame(height: 20)
            HStack {
                Text(formatTime(player.elapsed))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
                Spacer()
                Text("-\(formatTime(max(0, player.duration - player.elapsed)))")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
    }

    private var volumeRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "speaker.fill")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Slider(
                value: Binding(
                    get: { Double(player.volume) },
                    set: { appState.syncVolume(Float($0)) }
                ),
                in: 0...1
            )
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Fade buttons

    private var fadeButtons: some View {
        let isCortina = appState.displayState.mode == .cortina
        let mode = appState.fadeMode
        let autoFadeBlocksButtons: Bool = {
            guard appState.settings.autoFadeCortinasEnabled, isCortina else { return false }
            if appState.setlist.entries.first(where: { $0.id == player.currentEntryID })?.ignoresAutoFade == true { return false }
            let fade = appState.settings.builtInFadeDuration
            let play = appState.settings.cortinaPlayTime
            let dur = player.duration
            guard dur > 0 else { return true }
            let delay: Double
            if dur > play + fade      { delay = play }
            else if dur > fade        { delay = dur - fade }
            else                      { return true }
            return player.elapsed >= delay
        }()

        return HStack(spacing: 10) {
            Button {
                appState.transportFadeAndStop()
            } label: {
                Label(
                    mode == .fadeAndStop ? "Cancel" : "Fade & Stop",
                    systemImage: mode == .fadeAndStop ? "xmark.circle.fill" : "speaker.slash.fill"
                )
                .font(.system(size: 11, weight: .medium))
            }
            .buttonStyle(.bordered)
            .tint(mode == .fadeAndStop ? .red : nil)
            .disabled(mode == .fadeAndContinue || (mode == .none && (!isCortina || autoFadeBlocksButtons)))

            Button {
                appState.transportFadeAndContinue()
            } label: {
                Label(
                    mode == .fadeAndContinue ? "Cancel" : "Fade & Next",
                    systemImage: mode == .fadeAndContinue ? "xmark.circle.fill" : "speaker.wave.1"
                )
                .font(.system(size: 11, weight: .medium))
            }
            .buttonStyle(.bordered)
            .tint(mode == .fadeAndContinue ? .red : nil)
            .disabled(mode == .fadeAndStop || (mode == .none && (!isCortina || autoFadeBlocksButtons)))
        }
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let s = Int(seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}
