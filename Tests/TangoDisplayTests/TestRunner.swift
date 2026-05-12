// Lightweight test runner — no XCTest or Xcode required.
// Run with: swift run TangoDisplayTests
//
// Convention:
//   suite("SuiteName") { ... }      — groups tests, prints header
//   test("name") { ... }            — individual test, catches thrown errors
//   expect(_ condition, file:line:) — assertion; throws on failure

import Foundation
import TangoDisplayCore

// MARK: - Minimal test framework

private var totalPassed = 0
private var totalFailed = 0
private var currentSuite = ""

struct TestFailure: Error {
    let message: String
    let file: StaticString
    let line: Int
}

func expect(
    _ condition: @autoclosure () -> Bool,
    _ message: String = "",
    file: StaticString = #file,
    line: Int = #line
) throws {
    guard condition() else {
        let msg = message.isEmpty ? "Assertion failed" : message
        throw TestFailure(message: msg, file: file, line: line)
    }
}

func expectEqual<T: Equatable>(
    _ a: T,
    _ b: T,
    file: StaticString = #file,
    line: Int = #line
) throws {
    try expect(a == b, "Expected \(a) == \(b)", file: file, line: line)
}

func expectNil<T>(_ value: T?, file: StaticString = #file, line: Int = #line) throws {
    try expect(value == nil, "Expected nil but got \(String(describing: value))", file: file, line: line)
}

func expectNotNil<T>(_ value: T?, file: StaticString = #file, line: Int = #line) throws {
    try expect(value != nil, "Expected non-nil value", file: file, line: line)
}

func suite(_ name: String, _ body: () -> Void) {
    currentSuite = name
    print("\n── \(name) ──")
    body()
}

func test(_ name: String, body: () throws -> Void) {
    do {
        try body()
        print("  ✓ \(name)")
        totalPassed += 1
    } catch let failure as TestFailure {
        print("  ✗ \(name)")
        print("      \(failure.message) (\(failure.file):\(failure.line))")
        totalFailed += 1
    } catch {
        print("  ✗ \(name) — unexpected error: \(error)")
        totalFailed += 1
    }
}

// MARK: - CortinaDetector tests

func runCortinaDetectorTests() {
    suite("CortinaDetector — Allowlist only") {
        test("matching genre is cortina") {
            let d = CortinaDetector(useAllowlist: true, allowlistGenres: ["cortina"],
                                    useDenylist: false, denylistGenres: [])
            try expect(d.isCortina(genre: "Cortina"))
        }
        test("non-matching genre is not cortina") {
            let d = CortinaDetector(useAllowlist: true, allowlistGenres: ["cortina"],
                                    useDenylist: false, denylistGenres: [])
            try expect(!d.isCortina(genre: "Tango"))
        }
        test("case insensitive — CORTINA") {
            let d = CortinaDetector(useAllowlist: true, allowlistGenres: ["cortina"],
                                    useDenylist: false, denylistGenres: [])
            try expect(d.isCortina(genre: "CORTINA"))
            try expect(d.isCortina(genre: "cortina"))
            try expect(d.isCortina(genre: "Cortina"))
        }
        test("empty genre is NOT cortina under allowlist-only") {
            let d = CortinaDetector(useAllowlist: true, allowlistGenres: ["cortina"],
                                    useDenylist: false, denylistGenres: [])
            try expect(!d.isCortina(genre: ""))
        }
    }

    suite("CortinaDetector — Denylist only") {
        let d = CortinaDetector(useAllowlist: false, allowlistGenres: [],
                                useDenylist: true, denylistGenres: ["tango", "vals", "milonga"])
        test("dance genre is not cortina") {
            try expect(!d.isCortina(genre: "Tango"))
            try expect(!d.isCortina(genre: "Vals"))
            try expect(!d.isCortina(genre: "Milonga"))
        }
        test("non-dance genre is cortina") {
            try expect(d.isCortina(genre: "Pop"))
            try expect(d.isCortina(genre: "Cortina"))
        }
        test("empty genre is cortina") {
            try expect(d.isCortina(genre: ""))
        }
        test("case insensitive — TANGO") {
            try expect(!d.isCortina(genre: "TANGO"))
            try expect(!d.isCortina(genre: "Vals"))
        }
    }

    suite("CortinaDetector — Both rules (EITHER match → cortina)") {
        let d = CortinaDetector(useAllowlist: true, allowlistGenres: ["cortina"],
                                useDenylist: true, denylistGenres: ["tango", "vals", "milonga"])
        test("allowlist match is cortina") {
            try expect(d.isCortina(genre: "Cortina"))
        }
        test("denylist match is cortina (Pop not in dance genres)") {
            try expect(d.isCortina(genre: "Pop"))
        }
        test("dance genre is NOT cortina") {
            try expect(!d.isCortina(genre: "Tango"))
        }
    }

    suite("CortinaDetector — Neither rule") {
        let d = CortinaDetector(useAllowlist: false, allowlistGenres: ["cortina"],
                                useDenylist: false, denylistGenres: ["tango"])
        test("never cortina") {
            try expect(!d.isCortina(genre: "Cortina"))
            try expect(!d.isCortina(genre: "Pop"))
            try expect(!d.isCortina(genre: ""))
            try expect(!d.isCortina(genre: "Tango"))
        }
    }

    suite("CortinaDetector — Denylist partial match") {
        let d = CortinaDetector(useAllowlist: false, allowlistGenres: [],
                                useDenylist: true, denylistGenres: ["tango", "vals", "milonga"],
                                denylistPartialGenres: ["tango", "vals", "milonga"])
        test("exact match still not cortina") {
            try expect(!d.isCortina(genre: "Tango"))
            try expect(!d.isCortina(genre: "Vals"))
            try expect(!d.isCortina(genre: "Milonga"))
        }
        test("prefix match with space — not cortina") {
            try expect(!d.isCortina(genre: "Tango Instrumental"))
            try expect(!d.isCortina(genre: "Tango Vocals"))
            try expect(!d.isCortina(genre: "Vals Instrumental"))
            try expect(!d.isCortina(genre: "Milonga Vocal"))
        }
        test("case insensitive prefix match — not cortina") {
            try expect(!d.isCortina(genre: "tango instrumental"))
            try expect(!d.isCortina(genre: "TANGO VOCALS"))
        }
        test("no space after term — is cortina") {
            try expect(d.isCortina(genre: "Tangoed"))
            try expect(d.isCortina(genre: "Valses"))
        }
        test("unrelated genre — is cortina") {
            try expect(d.isCortina(genre: "Pop"))
            try expect(d.isCortina(genre: "Cortina"))
        }

        let noPartial = CortinaDetector(useAllowlist: false, allowlistGenres: [],
                                        useDenylist: true, denylistGenres: ["tango", "vals", "milonga"])
        test("without partial match, Tango Instrumental IS cortina") {
            try expect(noPartial.isCortina(genre: "Tango Instrumental"))
        }
        test("without partial match, exact Tango is still NOT cortina") {
            try expect(!noPartial.isCortina(genre: "Tango"))
        }
    }

    suite("CortinaDetector — Whitespace trimming") {
        let denyOnly = CortinaDetector(useAllowlist: false, allowlistGenres: [],
                                       useDenylist: true, denylistGenres: ["tango", "vals", "milonga"])
        test("leading space on denylist genre is NOT cortina") {
            try expect(!denyOnly.isCortina(genre: " Tango"))
        }
        test("trailing space on denylist genre is NOT cortina") {
            try expect(!denyOnly.isCortina(genre: "Tango "))
        }
        test("leading and trailing spaces is NOT cortina") {
            try expect(!denyOnly.isCortina(genre: "  Tango  "))
        }
        test("tab-padded denylist genre is NOT cortina") {
            try expect(!denyOnly.isCortina(genre: "\tTango"))
        }

        let allowOnly = CortinaDetector(useAllowlist: true, allowlistGenres: ["cortina"],
                                        useDenylist: false, denylistGenres: [])
        test("leading space on allowlist genre IS cortina") {
            try expect(allowOnly.isCortina(genre: " Cortina"))
        }
        test("trailing space on allowlist genre IS cortina") {
            try expect(allowOnly.isCortina(genre: "Cortina "))
        }

        let both = CortinaDetector(useAllowlist: true, allowlistGenres: ["cortina"],
                                   useDenylist: true, denylistGenres: ["tango", "vals", "milonga"])
        test("both rules: spaced Tango is NOT cortina") {
            try expect(!both.isCortina(genre: " Tango"))
        }
        test("both rules: spaced Cortina IS cortina") {
            try expect(both.isCortina(genre: " Cortina"))
        }

        test("spaces-only genre treated as empty -> cortina under denylist") {
            try expect(denyOnly.isCortina(genre: "   "))
        }
    }
}

// MARK: - TandaTracker tests

func runTandaTrackerTests() {
    let tracker = TandaTracker()
    let detector = CortinaDetector(useAllowlist: true, allowlistGenres: ["cortina"],
                                   useDenylist: false, denylistGenres: [])

    func tracks(_ genres: [String]) -> [Track] {
        genres.enumerated().map { i, g in
            Track(title: "T\(i)", artist: "A", genre: g, persistentID: "\(i)")
        }
    }

    suite("TandaTracker — Playlist-based position") {
        test("first track of tanda") {
            // C T T T C
            let t = tracks(["Cortina", "Tango", "Tango", "Tango", "Cortina"])
            let pos = tracker.position(tracks: t, currentIndex: 1, detector: detector)
            try expectEqual(pos?.current, 1)
            try expectEqual(pos?.total, 3)
        }
        test("mid-tanda") {
            let t = tracks(["Cortina", "Tango", "Tango", "Tango", "Cortina"])
            let pos = tracker.position(tracks: t, currentIndex: 2, detector: detector)
            try expectEqual(pos?.current, 2)
            try expectEqual(pos?.total, 3)
        }
        test("last track of tanda") {
            let t = tracks(["Cortina", "Tango", "Tango", "Tango", "Cortina"])
            let pos = tracker.position(tracks: t, currentIndex: 3, detector: detector)
            try expectEqual(pos?.current, 3)
            try expectEqual(pos?.total, 3)
        }
        test("single-track tanda") {
            let t = tracks(["Cortina", "Tango", "Cortina"])
            let pos = tracker.position(tracks: t, currentIndex: 1, detector: detector)
            try expectEqual(pos?.current, 1)
            try expectEqual(pos?.total, 1)
        }
        test("tanda at start of playlist (no leading cortina)") {
            let t = tracks(["Tango", "Tango", "Tango", "Cortina"])
            let pos = tracker.position(tracks: t, currentIndex: 1, detector: detector)
            try expectEqual(pos?.current, 2)
            try expectEqual(pos?.total, 3)
        }
        test("tanda at end of playlist (no trailing cortina)") {
            let t = tracks(["Cortina", "Tango", "Tango", "Tango"])
            let pos = tracker.position(tracks: t, currentIndex: 3, detector: detector)
            try expectEqual(pos?.current, 3)
            try expectEqual(pos?.total, 3)
        }
        test("current is cortina → returns nil") {
            let t = tracks(["Cortina", "Tango"])
            let pos = tracker.position(tracks: t, currentIndex: 0, detector: detector)
            try expectNil(pos)
        }
        test("out of bounds → returns nil") {
            let t = tracks(["Tango"])
            try expectNil(tracker.position(tracks: t, currentIndex: -1, detector: detector))
            try expectNil(tracker.position(tracks: t, currentIndex: 5, detector: detector))
        }
        test("second tanda in playlist") {
            // C T T C T T T C
            let t = tracks(["Cortina", "Tango", "Tango", "Cortina", "Tango", "Tango", "Tango", "Cortina"])
            let pos = tracker.position(tracks: t, currentIndex: 5, detector: detector)
            try expectEqual(pos?.current, 2)
            try expectEqual(pos?.total, 3)
        }
    }

    suite("TandaTracker — History-based position") {
        func h(_ n: Int) -> [Track] {
            (0..<n).map { Track(title: "T\($0)", artist: "A", genre: "Tango", persistentID: "\($0)") }
        }
        test("single track") {
            let pos = tracker.positionFromHistory(h(1))
            try expectEqual(pos?.current, 1)
            try expectNil(pos?.total)
        }
        test("multiple tracks") {
            let pos = tracker.positionFromHistory(h(3))
            try expectEqual(pos?.current, 3)
            try expectNil(pos?.total)
        }
        test("empty history returns nil") {
            try expectNil(tracker.positionFromHistory([]))
        }
    }
}

// MARK: - ProfileStore tests

func runProfileStoreTests() {
    suite("ProfileStore — Round-trip save/load/delete") {
        test("save and reload user profile") {
            let tmpDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("TangoDisplayTests-\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tmpDir) }

            let store = ProfileStore(storeURL: tmpDir)
            let profile = AppearanceProfile(
                id: UUID(), name: "Test Profile", isBuiltIn: false,
                backgroundColor: "#FF0000"
            )
            try store.save(profile)

            // Load from disk into a fresh store
            let store2 = ProfileStore(storeURL: tmpDir)
            store2.load()
            try expect(store2.userProfiles.count == 1, "Expected 1 user profile, got \(store2.userProfiles.count)")
            try expectEqual(store2.userProfiles[0].id, profile.id)
            try expectEqual(store2.userProfiles[0].backgroundColor, "#FF0000")
        }

        test("update existing profile") {
            let tmpDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("TangoDisplayTests-\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tmpDir) }

            let store = ProfileStore(storeURL: tmpDir)
            var profile = AppearanceProfile(id: UUID(), name: "A", isBuiltIn: false)
            try store.save(profile)
            profile.name = "B"
            try store.save(profile)
            try expectEqual(store.userProfiles.count, 1)
            try expectEqual(store.userProfiles[0].name, "B")
        }

        test("delete user profile") {
            let tmpDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("TangoDisplayTests-\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tmpDir) }

            let store = ProfileStore(storeURL: tmpDir)
            let profile = AppearanceProfile(id: UUID(), name: "Del", isBuiltIn: false)
            try store.save(profile)
            try expectEqual(store.userProfiles.count, 1)
            try store.delete(profile)
            try expectEqual(store.userProfiles.count, 0)
            // Verify file is gone
            let fileURL = tmpDir.appendingPathComponent("\(profile.id.uuidString).json")
            try expect(!FileManager.default.fileExists(atPath: fileURL.path), "File should be deleted")
        }

        test("built-in profiles are never written to disk") {
            let tmpDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("TangoDisplayTests-\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tmpDir) }

            let store = ProfileStore(storeURL: tmpDir)
            do {
                try store.save(AppearanceProfile.classic)
                try expect(false, "Should have thrown for built-in profile")
            } catch ProfileStoreError.cannotModifyBuiltIn {
                // Expected
            }
            let files = (try? FileManager.default.contentsOfDirectory(atPath: tmpDir.path)) ?? []
            try expect(files.isEmpty, "No files should exist for built-in profile")
        }

        test("delete built-in profile throws") {
            let tmpDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("TangoDisplayTests-\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tmpDir) }

            let store = ProfileStore(storeURL: tmpDir)
            do {
                try store.delete(AppearanceProfile.modern)
                try expect(false, "Should have thrown for built-in profile")
            } catch ProfileStoreError.cannotModifyBuiltIn {
                // Expected
            }
        }

        test("allProfiles prepends built-ins") {
            let tmpDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("TangoDisplayTests-\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tmpDir) }

            let store = ProfileStore(storeURL: tmpDir)
            let user = AppearanceProfile(id: UUID(), name: "My Profile", isBuiltIn: false)
            try store.save(user)
            let all = store.allProfiles
            try expect(all.count == AppearanceProfile.builtIns.count + 1)
            try expect(all.prefix(AppearanceProfile.builtIns.count)
                          .map(\.id) == AppearanceProfile.builtIns.map(\.id),
                       "Built-ins should come first")
        }
    }
}

// MARK: - DisplayState transition tests (pure logic, no AppKit)

func runDisplayStateTests() {
    // Helper: simulate the core logic that AppState applies
    let detector = CortinaDetector(
        useAllowlist: true, allowlistGenres: ["cortina"],
        useDenylist: true, denylistGenres: ["tango", "vals", "milonga"]
    )
    let tracker = TandaTracker()

    func track(_ title: String, genre: String, pid: String? = nil) -> Track {
        Track(title: title, artist: "A", genre: genre, persistentID: pid ?? title)
    }

    suite("DisplayState — Mode transitions") {
        test("stopped → idle") {
            var state = DisplayState(mode: .playing, currentTrack: track("A", genre: "Tango"))
            // Simulate stopping
            state = DisplayState()
            try expectEqual(state.mode, .idle)
            try expectNil(state.currentTrack)
        }

        test("playing → cortina clears tanda position") {
            var state = DisplayState(mode: .playing,
                                     currentTrack: track("A", genre: "Tango"),
                                     tandaPosition: TandaPosition(current: 2, total: 4))
            let cortina = track("C", genre: "Cortina")
            state = DisplayState(mode: .cortina, currentTrack: cortina)
            try expectEqual(state.mode, .cortina)
            try expectNil(state.tandaPosition)
        }

        test("cortina → playing sets mode correctly") {
            var state = DisplayState(mode: .cortina)
            let tango = track("A", genre: "Tango")
            let pos = tracker.positionFromHistory([tango])
            state = DisplayState(mode: .playing, currentTrack: tango, tandaPosition: pos)
            try expectEqual(state.mode, .playing)
            try expectEqual(state.currentTrack?.genre, "Tango")
            try expectEqual(state.tandaPosition?.current, 1)
        }

        test("override mode ignores track updates") {
            var state = DisplayState(mode: .override, overrideText: "Custom Message")
            // Simulate logic: if mode == .override, don't update
            let newTrack = track("NewTrack", genre: "Tango")
            let shouldUpdate = state.mode != .override
            if shouldUpdate { state.currentTrack = newTrack }
            try expectEqual(state.mode, .override)
            try expect(state.currentTrack == nil, "Override mode should ignore track changes")
            try expectEqual(state.overrideText, "Custom Message")
        }

        test("override cleared returns to idle") {
            var state = DisplayState(mode: .override, overrideText: "Custom")
            state = DisplayState()  // clearOverride resets to idle
            try expectEqual(state.mode, .idle)
            try expectNil(state.overrideText)
        }

        test("empty genre treated as cortina under denylist") {
            let isCortina = detector.isCortina(genre: "")
            try expect(isCortina, "Empty genre should be detected as cortina")
        }

        test("paused mode preserves content") {
            let tango = track("A", genre: "Tango")
            var state = DisplayState(mode: .playing, currentTrack: tango,
                                     tandaPosition: TandaPosition(current: 2, total: 4))
            // Simulate pause: change mode only
            state.mode = .paused
            try expectEqual(state.mode, .paused)
            try expectEqual(state.currentTrack?.title, "A")
            try expectEqual(state.tandaPosition?.current, 2)
        }

        test("next track set during cortina") {
            let cortina = track("C", genre: "Cortina")
            let nextTango = track("Di Sarli", genre: "Tango")
            let state = DisplayState(mode: .cortina, currentTrack: cortina, nextTrack: nextTango)
            try expectEqual(state.mode, .cortina)
            try expectEqual(state.nextTrack?.title, "Di Sarli")
        }

        test("upcoming track uses cortina's real position, not stale index") {
            // Playlist: dance, dance, cortina, dance, dance
            // Simulates the user skipping to the cortina at index 2 while
            // playlistCurrentIndex is stale at 0.
            let tracks: [Track] = [
                track("D1", genre: "Tango",   pid: "d1"),
                track("D2", genre: "Tango",   pid: "d2"),
                track("C1", genre: "Cortina", pid: "c1"),
                track("D3", genre: "Tango",   pid: "d3"),
                track("D4", genre: "Tango",   pid: "d4"),
            ]
            let cortina = tracks[2]

            // Simulate stale index (pointing before the cortina)
            var staleIndex = 0
            // Anchor to real position via persistentID lookup (the fix)
            if let idx = tracks.firstIndex(where: { $0.persistentID == cortina.persistentID }) {
                staleIndex = idx
            }
            // Forward scan from correct position
            let startSearch = staleIndex + 1
            let nextTrack = startSearch < tracks.count
                ? tracks[startSearch...].first { !detector.isCortina(genre: $0.genre) }
                : nil

            try expect(nextTrack?.persistentID == "d3",
                       "Upcoming track should be D3 (after the cortina), not D1")
        }

        test("upcoming track is nil when cortina is last in playlist") {
            let tracks: [Track] = [
                track("D1", genre: "Tango",   pid: "d1"),
                track("C1", genre: "Cortina", pid: "c1"),
            ]
            let cortina = tracks[1]
            var idx = 0
            if let i = tracks.firstIndex(where: { $0.persistentID == cortina.persistentID }) {
                idx = i
            }
            let startSearch = idx + 1
            let nextTrack = startSearch < tracks.count
                ? tracks[startSearch...].first { !detector.isCortina(genre: $0.genre) }
                : nil
            try expect(nextTrack == nil, "No upcoming track when cortina is last in playlist")
        }

        test("playlist-based tanda position during playing") {
            let tracks: [Track] = [
                track("C1", genre: "Cortina", pid: "c1"),
                track("T1", genre: "Tango", pid: "t1"),
                track("T2", genre: "Tango", pid: "t2"),
                track("T3", genre: "Tango", pid: "t3"),
                track("C2", genre: "Cortina", pid: "c2"),
            ]
            let pos = tracker.position(tracks: tracks, currentIndex: 2, detector: detector)
            let state = DisplayState(mode: .playing,
                                     currentTrack: tracks[2],
                                     tandaPosition: pos)
            try expectEqual(state.tandaPosition?.current, 2)
            try expectEqual(state.tandaPosition?.total, 3)
        }
    }
}

// MARK: - Main entry point

runCortinaDetectorTests()
runTandaTrackerTests()
runProfileStoreTests()
runDisplayStateTests()

print("\n════════════════════════════════")
let icon = totalFailed == 0 ? "✓" : "✗"
print("\(icon) \(totalPassed) passed, \(totalFailed) failed")
print("════════════════════════════════")

if totalFailed > 0 {
    exit(1)
}
