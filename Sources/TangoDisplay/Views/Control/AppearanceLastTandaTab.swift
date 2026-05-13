import AppKit
import SwiftUI
import TangoDisplayCore

struct AppearanceLastTandaTab: View {
    @Binding var working: AppearanceProfile
    @EnvironmentObject var settings: AppSettings

    private let availableFonts: [String] = ["System"] + NSFontManager.shared.availableFontFamilies.sorted()

    var body: some View {
        Form {
            Section {
                TextField("Label Text", text: $settings.lastTandaLabel,
                          prompt: Text("e.g. LAST TANDA"))
                    .lineLimit(1)
                HStack {
                    Text("Colour")
                    Spacer()
                    ColorPicker("", selection: Binding(
                        get: { Color(hex: working.lastTandaLabelColor) },
                        set: { working.lastTandaLabelColor = $0.hexString }
                    ))
                    .labelsHidden()
                    .frame(width: 44)
                }
                fontRow("Font",
                        name:   $working.lastTandaLabelFontName,
                        size:   $working.lastTandaLabelFontSize,
                        bold:   $working.lastTandaLabelFontBold,
                        italic: $working.lastTandaLabelFontItalic)
                Toggle("Show in Display", isOn: $working.showLastTandaLabel)
            } header: {
                Text("Last Tanda Label")
                    .foregroundColor(ControlTheme.accent)
            } footer: {
                Label {
                    Text("Mark a cortina via right-click in the setlist to trigger Last Tanda mode.")
                } icon: {
                    Image(systemName: "info.circle")
                }
            }

        }
        .formStyle(.grouped)
    }

    // MARK: - Font row helper

    private func fontRow(_ label: String, name: Binding<String>, size: Binding<Double>,
                         bold: Binding<Bool>, italic: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .frame(width: 100, alignment: .leading)
            Picker("", selection: name) {
                ForEach(availableFonts, id: \.self) { family in
                    Text(family).tag(family)
                }
            }
            .labelsHidden()
            .frame(width: 180)
            Spacer()
            Stepper(value: size, in: 8...200, step: 2) {
                Text(String(format: "%.0fpt", size.wrappedValue))
                    .monospacedDigit()
                    .frame(width: 44)
            }
            Toggle("B", isOn: bold)
                .toggleStyle(.button)
                .font(.system(size: 12, weight: .bold))
                .help("Bold")
            Toggle("I", isOn: italic)
                .toggleStyle(.button)
                .font(.system(size: 12).italic())
                .help("Italic")
        }
    }
}
