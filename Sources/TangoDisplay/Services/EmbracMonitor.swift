import Foundation
import TangoDisplayCore

/// Monitors Embrace via a hybrid push+poll strategy.
///
/// Embrace's distributed notification `com.iccir.Embrace.playerUpdate` fires on
/// every track change and state change, so we use it to trigger an immediate poll
/// rather than waiting for the 2-second timer. The timer runs as a fallback for
/// initial state on app start, recovery after Embrace quits, and watchdog backoff.
///
/// AppleScript is executed via /usr/bin/osascript (Process) rather than
/// NSAppleScript to avoid per-call compilation overhead; TCC attributes the
/// subprocess's Apple Events to the parent app (TangoDisplay).
///
/// Playlist enumeration is not supported — triggerPlaylistFetch() is a no-op and
/// onPlaylistUpdate is never called. AppState's history-based tanda counting
/// fallback handles this automatically (same behaviour as SwinsianMonitor).
final class EmbracMonitor {

    private static let updateNotification = "com.iccir.Embrace.playerUpdate"

    private let scriptQueue = DispatchQueue(label: "com.tangodisplay.embrace", qos: .utility)

    private var timer: DispatchSourceTimer?
    private var notificationObserver: AnyObject?

    private var consecutiveFailures = 0
    private var currentInterval: TimeInterval = 2.0
    private let normalInterval: TimeInterval = 2.0
    private let maxInterval: TimeInterval = 30.0
    private let failuresBeforeWatchdog = 3

    // MARK: - MusicPlayerSource callbacks (all delivered on main queue)

    var onTrackUpdate: ((Track?, PlayerState) -> Void)?
    var onPlaylistUpdate: ((tracks: [Track], currentIndex: Int)?) -> Void = { _ in }
    var onWatchdogChanged: ((Bool) -> Void)?

    // MARK: - AppleScript source

    /// Returns five newline-delimited fields: state, title, artist, genre, id.
    /// Uses current index + track N lookup (Embrace uses 1-based indexing; 0 = no track loaded).
    /// Uses `player state as string` because Embrace's dictionary does not export `paused`
    /// as a named constant — comparing `player state is paused` throws -2753 at runtime.
    private static let trackScript = """
        tell application "Embrace"
            try
                set idx to current index
                if idx is 0 then
                    return "stopped" & linefeed & "" & linefeed & "" & linefeed & "" & linefeed & ""
                end if
                set t to track idx
                set theTitle to title of t
                set theArtist to artist of t
                if theArtist is missing value then set theArtist to ""
                set theGenre to genre of t
                if theGenre is missing value then set theGenre to ""
                set theID to id of t
                set stateStr to player state as string
                if stateStr is "stopped" then
                    return "stopped" & linefeed & "" & linefeed & "" & linefeed & "" & linefeed & ""
                end if
                return stateStr & linefeed & theTitle & linefeed & theArtist & linefeed & theGenre & linefeed & theID
            on error
                return "stopped" & linefeed & "" & linefeed & "" & linefeed & "" & linefeed & ""
            end try
        end tell
        """

    // MARK: - Lifecycle

    func start() {
        onWatchdogChanged?(false)

        let observer = DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name(Self.updateNotification),
            object: nil,
            queue: nil   // delivered on whatever thread DNC chooses; we dispatch to scriptQueue
        ) { [weak self] _ in
            self?.notificationTriggeredPoll()
        }
        notificationObserver = observer

        schedulePoll(after: 0)
    }

    func stop() {
        timer?.cancel()
        timer = nil
        if let observer = notificationObserver {
            DistributedNotificationCenter.default().removeObserver(observer)
            notificationObserver = nil
        }
    }

    // MARK: - Scheduling

    private func notificationTriggeredPoll() {
        scriptQueue.async { [weak self] in
            guard let self else { return }
            self.timer?.cancel()
            self.timer = nil
            self.doPoll()
        }
    }

    private func schedulePoll(after delay: TimeInterval) {
        let t = DispatchSource.makeTimerSource(queue: scriptQueue)
        t.schedule(deadline: .now() + delay)
        t.setEventHandler { [weak self] in self?.doPoll() }
        t.resume()
        timer = t
    }

    // MARK: - Polling

    private func doPoll() {
        // Must be called on scriptQueue
        if let output = runScript() {
            handleSuccess()
            let result = parseOutput(output)
            DispatchQueue.main.async { [weak self] in
                self?.onTrackUpdate?(result.0, result.1)
            }
        } else {
            handleFailure()
            DispatchQueue.main.async { [weak self] in
                self?.onTrackUpdate?(nil, .stopped)
            }
        }
        schedulePoll(after: currentInterval)
    }

    // MARK: - Script execution

    /// Runs the AppleScript via /usr/bin/osascript and returns stdout, or nil on failure.
    /// Must be called on scriptQueue (it blocks until the subprocess exits).
    private func runScript() -> String? {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments = ["-e", Self.trackScript]

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        proc.standardOutput = stdoutPipe
        proc.standardError  = stderrPipe

        do {
            try proc.run()
        } catch {
            NSLog("TangoDisplay: Embrace osascript launch failed: %@", error.localizedDescription)
            return nil
        }

        proc.waitUntilExit()

        guard proc.terminationStatus == 0 else {
            let errData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
            let errMsg  = String(data: errData, encoding: .utf8) ?? ""
            NSLog("TangoDisplay: Embrace osascript error (%d): %@",
                  proc.terminationStatus, errMsg.trimmingCharacters(in: .whitespacesAndNewlines))
            return nil
        }

        let data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Output parsing

    /// Parses five newline-delimited fields: state, title, artist, genre, id.
    private func parseOutput(_ output: String) -> (Track?, PlayerState) {
        // osascript appends a trailing newline; split keeping empty strings to preserve indices
        let lines = output.components(separatedBy: "\n")

        let stateRaw = lines.count > 0 ? lines[0].trimmingCharacters(in: .whitespaces) : "stopped"
        let state    = PlayerState(rawValue: stateRaw) ?? .stopped

        guard state != .stopped else { return (nil, .stopped) }

        let title  = lines.count > 1 ? lines[1] : ""
        let artist = lines.count > 2 ? lines[2] : ""
        let genre  = lines.count > 3 ? lines[3] : ""
        let pid    = lines.count > 4 ? lines[4].trimmingCharacters(in: .whitespaces) : ""

        guard !pid.isEmpty || !title.isEmpty else { return (nil, .stopped) }

        return (Track(title: title, artist: artist, genre: genre, persistentID: pid), state)
    }

    // MARK: - Watchdog

    private func handleSuccess() {
        let wasWatchdog = consecutiveFailures >= failuresBeforeWatchdog
        consecutiveFailures = 0
        currentInterval = normalInterval
        if wasWatchdog {
            DispatchQueue.main.async { [weak self] in self?.onWatchdogChanged?(false) }
        }
    }

    private func handleFailure() {
        consecutiveFailures += 1
        if consecutiveFailures == failuresBeforeWatchdog {
            DispatchQueue.main.async { [weak self] in self?.onWatchdogChanged?(true) }
        }
        if consecutiveFailures >= failuresBeforeWatchdog {
            currentInterval = min(currentInterval * 2, maxInterval)
        }
    }
}

// MARK: - MusicPlayerSource conformance

extension EmbracMonitor: MusicPlayerSource {
    func pollNow() {
        scriptQueue.async { [weak self] in
            guard let self else { return }
            self.timer?.cancel()
            self.timer = nil
            self.doPoll()
        }
    }

    func triggerPlaylistFetch() {}   // no Embrace setlist API
}
