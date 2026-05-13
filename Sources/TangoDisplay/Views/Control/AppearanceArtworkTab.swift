import AppKit
import SwiftUI
import TangoDisplayCore

struct AppearanceArtworkTab: View {
    @Binding var working: AppearanceProfile
    let bgThumbnail: NSImage?
    let onPickImage: () -> Void
    let onClearImage: () -> Void

    var body: some View {
        Form {
            Section {
                Picker("Style", selection: $working.transitionStyle) {
                    ForEach(TransitionStyle.allCases, id: \.self) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                HStack {
                    Text("Duration")
                    Slider(value: $working.transitionDuration, in: 0...2, step: 0.1)
                    Text(String(format: "%.1fs", working.transitionDuration))
                        .monospacedDigit()
                        .frame(width: 36)
                }
            } header: {
                Text("Transition")
                    .foregroundColor(ControlTheme.accent)
            }

            Section {
                Toggle("Show artwork on dance tracks", isOn: $working.showArtworkDance)
                if working.showArtworkDance || working.showArtworkCortina {
                    HStack {
                        Text("Opacity")
                        Slider(value: $working.albumArtworkOpacity, in: 0...1)
                        Text(String(format: "%.0f%%", working.albumArtworkOpacity * 100))
                            .monospacedDigit()
                            .frame(width: 44)
                    }
                    HStack {
                        Text("Scale")
                        Slider(value: $working.albumArtworkScale, in: 0.1...5.0)
                        Text(String(format: "%.2f×", working.albumArtworkScale))
                            .monospacedDigit()
                            .frame(width: 44)
                    }
                    HStack {
                        Text("Horizontal Position")
                        Slider(value: $working.albumArtworkOffsetX, in: -2000...2000)
                        Text(String(format: "%+.0f", working.albumArtworkOffsetX))
                            .monospacedDigit()
                            .frame(width: 48)
                    }
                    HStack {
                        Text("Vertical Position")
                        Slider(value: $working.albumArtworkOffsetY, in: -2000...2000)
                        Text(String(format: "%+.0f", working.albumArtworkOffsetY))
                            .monospacedDigit()
                            .frame(width: 48)
                    }
                }
            } header: {
                Text("Album Artwork")
                    .foregroundColor(ControlTheme.accent)
            }

            Section {
                HStack(spacing: 12) {
                    Group {
                        if let thumb = bgThumbnail {
                            Image(nsImage: thumb)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipped()
                                .cornerRadius(4)
                        } else {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.secondary)
                                )
                        }
                    }
                    Spacer()
                    Button(working.backgroundImageFilename == nil ? "Pick Image…" : "Change Image…") {
                        onPickImage()
                    }
                    .buttonStyle(.bordered)
                    if working.backgroundImageFilename != nil {
                        Button("Clear") { onClearImage() }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                    }
                }

                if working.backgroundImageFilename != nil {
                    HStack {
                        Text("Opacity")
                        Slider(value: $working.backgroundImageOpacity, in: 0...1)
                        Text(String(format: "%.0f%%", working.backgroundImageOpacity * 100))
                            .monospacedDigit()
                            .frame(width: 36)
                    }
                    HStack {
                        Text("Scale")
                        Slider(value: $working.backgroundImageScale, in: 0.1...5.0)
                        Text(String(format: "%.2f×", working.backgroundImageScale))
                            .monospacedDigit()
                            .frame(width: 44)
                    }
                    HStack {
                        Text("Horizontal Position")
                        Slider(value: $working.backgroundImageOffsetX, in: -2000...2000)
                        Text(String(format: "%+.0f", working.backgroundImageOffsetX))
                            .monospacedDigit()
                            .frame(width: 48)
                    }
                    HStack {
                        Text("Vertical Position")
                        Slider(value: $working.backgroundImageOffsetY, in: -2000...2000)
                        Text(String(format: "%+.0f", working.backgroundImageOffsetY))
                            .monospacedDigit()
                            .frame(width: 48)
                    }
                    Toggle("Dim background behind text", isOn: $working.dimBackgroundBehindText)
                }
            } header: {
                Text("Background Image")
                    .foregroundColor(ControlTheme.accent)
            } footer: {
                Label {
                    Text("Background images are best checked in Live because external display resolution can vary.")
                } icon: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .formStyle(.grouped)
    }
}
