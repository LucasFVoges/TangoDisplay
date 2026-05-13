import SwiftUI
import TangoDisplayCore

struct AppearanceCortinaTab: View {
    @Binding var working: AppearanceProfile

    var body: some View {
        Form {
            Section {
                Toggle("Show cortina track during cortina", isOn: $working.showCortinaTrackDuringCortina)
                Toggle("Show next track during cortina",   isOn: $working.showNextTrackDuringCortina)
                Toggle("Show Cortina Artist", isOn: $working.showCortinaTrackArtist)
                    .disabled(!working.showCortinaTrackDuringCortina)
                Toggle("Show Cortina Title",  isOn: $working.showCortinaTrackTitle)
                    .disabled(!working.showCortinaTrackDuringCortina)
            } header: {
                Text("Cortina Display")
                    .foregroundColor(ControlTheme.accent)
            }
        }
        .formStyle(.grouped)
    }
}
