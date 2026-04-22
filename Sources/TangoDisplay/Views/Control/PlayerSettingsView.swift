import SwiftUI

struct PlayerSettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Form {
            Section {
                Picker("Music player", selection: $settings.selectedPlayer) {
                    ForEach(MusicPlayerChoice.allCases) { choice in
                        Text(choice.displayName).tag(choice)
                    }
                }
                .pickerStyle(.radioGroup)
            } header: {
                Text("Player Source")
                    .foregroundColor(ControlTheme.accent)
            }

            Section {
                playerStatusInfo
            } header: {
                Text("Notes")
                    .foregroundColor(ControlTheme.accent)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    @ViewBuilder
    private var playerStatusInfo: some View {
        switch settings.selectedPlayer {
        case .musicApp:
            Label {
                Text("Polls Music.app every 2 seconds via AppleScript. Playlist look-ahead and tanda counting are fully supported.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }

        case .swinsian:
            VStack(alignment: .leading, spacing: 8) {
                Label {
                    Text("Listens for Swinsian push notifications in real time.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                Label {
                    Text("Playlist look-ahead is unavailable — Swinsian has no playlist API. Tanda counting uses track history only. During a cortina, upcoming tanda information will also be unavailable.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
