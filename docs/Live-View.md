# Live View

The **Live** section is the main control window. It shows what is currently playing, a live preview of the dancer display, and quick-action buttons.

![Live view](https://raw.githubusercontent.com/richardsladetdj-creator/TangoDisplay/main/docs/screenshots/live-view.png)

---

## Status indicators

At the bottom of the preview area:

| Indicator | Meaning |
|---|---|
| **Playing** (green) | Music.app is playing a track |
| **Polling OK** (green) | TangoDisplay successfully read track data on the last poll |
| **Paused** | The display is manually paused (dancer screen is frozen) |

---

## Action buttons

| Button | Shortcut | What it does |
|---|---|---|
| **Force Poll** | `⌘⇧R` | Immediately triggers a Music.app re-read, bypassing the normal notification/fallback-poll cycle |
| **Override…** | `⌘⇧O` | Opens a dialog to manually set what text appears on the display |
| **Pause Display** | `⌘⇧P` | Freezes the dancer screen; pressing again resumes live updates |

All three shortcuts work globally — you don't need to switch to TangoDisplay first.

---

## Track info panel

Below the buttons, TangoDisplay shows the currently detected values:

- **Title** — track name (may include vocalist in parentheses)
- **Artist** — orchestra / artist name
- **Genre** — the genre tag from Music.app
- **Tanda** — position within the current tanda, e.g. "Track 1 of 4"

---

## Debug log

The **Debug Log** disclosure item at the bottom expands to show recent polling events, AppleScript results, and cortina detection decisions. Useful for troubleshooting unexpected behaviour.
