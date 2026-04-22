import SwiftUI

// MARK: - Sidebar navigation items

enum SidebarItem: String, Hashable, CaseIterable {
    case live
    case cortinaRules
    case appearance
    case display
    case player
    case profiles

    var label: String {
        switch self {
        case .live:          return "Live"
        case .cortinaRules:  return "Cortina Rules"
        case .appearance:    return "Appearance"
        case .display:       return "Display"
        case .player:        return "Player"
        case .profiles:      return "Profiles"
        }
    }

    var icon: String {
        switch self {
        case .live:          return "play.circle.fill"
        case .cortinaRules:  return "music.note"
        case .appearance:    return "paintbrush"
        case .display:       return "display"
        case .player:        return "music.note.list"
        case .profiles:      return "paintpalette"
        }
    }

    var section: String {
        switch self {
        case .live:                               return "Live"
        case .cortinaRules, .appearance, .display, .player: return "Settings"
        case .profiles:                           return "Profiles"
        }
    }
}

// MARK: - Main control view

struct ControlView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) private var openWindow
    @State private var selectedItem: SidebarItem? = .live
    @State private var pendingSelection: SidebarItem? = nil
    @State private var showingUnsavedChangesAlert = false
    @State private var showingOverride = false

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detail
        }
        .frame(minWidth: 700, minHeight: 500)
        .preferredColorScheme(.dark)
        .alert("Unsaved Changes", isPresented: $showingUnsavedChangesAlert) {
            Button("Leave Without Saving", role: .destructive) {
                appState.hasUnsavedAppearanceChanges = false
                selectedItem = pendingSelection
                pendingSelection = nil
            }
            Button("Stay", role: .cancel) {
                pendingSelection = nil
            }
        } message: {
            Text("You have unsaved appearance changes. Leave without saving?")
        }
        .background(ControlWindowAccessor())
        .onAppear {
            WindowManager.ensureOpen(openWindow: openWindow)
            appState.reopenPresentationWindow = { openWindow(id: "presentation") }
            if let displayID = appState.settings.targetDisplayID {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    WindowManager.moveTo(displayID: displayID)
                }
            }
        }
        .sheet(isPresented: $showingOverride) {
            OverrideDialog(isPresented: $showingOverride)
                .environmentObject(appState)
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .showOverrideDialog)
        ) { _ in
            showingOverride = true
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .hotkeyPermissionRequired)
        ) { _ in
            appState.appendDebugLog("⚠ Global hotkeys require Input Monitoring in System Settings › Privacy & Security")
        }
    }

    // MARK: - Sidebar

    private var selectionBinding: Binding<SidebarItem?> {
        Binding(
            get: { selectedItem },
            set: { newValue in
                if selectedItem == .appearance,
                   appState.hasUnsavedAppearanceChanges,
                   newValue != .appearance {
                    pendingSelection = newValue
                    showingUnsavedChangesAlert = true
                } else {
                    selectedItem = newValue
                }
            }
        )
    }

    private var sidebar: some View {
        List(selection: selectionBinding) {
            Section("Live") {
                sidebarRow(.live)
            }
            Section("Settings") {
                sidebarRow(.cortinaRules)
                sidebarRow(.appearance)
                sidebarRow(.display)
                sidebarRow(.player)
            }
            Section("Profiles") {
                sidebarRow(.profiles)
            }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 160, ideal: 180, max: 220)
    }

    private func sidebarRow(_ item: SidebarItem) -> some View {
        Label(item.label, systemImage: item.icon)
            .tag(item)
    }

    // MARK: - Detail

    @ViewBuilder
    private var detail: some View {
        switch selectedItem {
        case .live, .none:
            liveView
        case .cortinaRules:
            CortinaSettingsView()
                .environmentObject(appState)
                .environmentObject(appState.settings)
        case .appearance:
            AppearanceSettingsView()
                .environmentObject(appState)
                .environmentObject(appState.settings)
        case .display:
            DisplaySettingsView()
                .environmentObject(appState)
                .environmentObject(appState.settings)
        case .player:
            PlayerSettingsView()
                .environmentObject(appState)
                .environmentObject(appState.settings)
        case .profiles:
            ProfilesView()
                .environmentObject(appState.settings)
        }
    }

    private var liveView: some View {
        HSplitView {
            VStack(spacing: 0) {
                if appState.settings.mirrorMode {
                    PreviewPane()
                        .frame(minWidth: 400)
                }
                Divider()
                StatusPane(showingOverride: $showingOverride)
                    .frame(maxWidth: .infinity)
            }
            .frame(minWidth: 380)
        }
    }
}

// MARK: - Notification names

extension Notification.Name {
    static let showOverrideDialog = Notification.Name("com.tangodisplay.showOverrideDialog")
    static let hotkeyPermissionRequired = Notification.Name("com.tangodisplay.hotkeyPermissionRequired")
}

// MARK: - Control window accessor

/// Captures the control window's NSWindow and attaches CloseGuard so the
/// red ✕ button triggers a quit confirmation instead of silently closing.
private struct ControlWindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { [weak view] in
            if let window = view?.window {
                window.delegate = CloseGuard.shared
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
