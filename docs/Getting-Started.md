# Getting Started

## System requirements

- macOS 13 Ventura or later
- An external monitor for the dancer display (optional but recommended)
- Music.app — only required when using the Music.app, Swinsian, or Embrace player sources. Not needed with the built-in player.

---

## Installation

### Option A — Download (easiest)

1. Go to the [Releases](https://github.com/richardsladetdj-creator/TangoDisplay/releases) page
2. Download `TangoDisplay-v3.8.0-universal.zip`
3. Unzip and drag `TangoDisplay.app` to `/Applications`
4. **Right-click › Open** on first launch — macOS will warn that the app isn't notarised; click **Open** to proceed

### Option B — Build from source

You need Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/richardsladetdj-creator/TangoDisplay.git
cd TangoDisplay
./Install.sh
```

`Install.sh` builds a release binary, assembles the `.app` bundle, code-signs it, and installs it to `/Applications`.

---

## First launch

When TangoDisplay starts it appears as a small display icon in the menu bar.

Click the icon to reveal the menu:

- **Show Display Window** — brings the presentation window to the front
- **Show Settings Window** — opens the main control window
- **Show Setlist** — opens the control window and jumps directly to the Setlist tab
- **Quit TangoDisplay** — exits the app

---

## Permissions

macOS may ask for up to two permissions depending on which features you use:

| Permission | When | Why |
|---|---|---|
| **Automation › Music** | First poll (Music.app, Swinsian, or Embrace sources only) | TangoDisplay reads the currently playing track, artist, genre, playlist position, and upcoming tracks via AppleScript. Not required when using the Built-in Player. |
| **Input Monitoring** | First hotkey use | Required so global keyboard shortcuts (`⌘⇧O`, `⌘⇧P`, `⌘⇧R`) work while other apps are in focus. |

To grant Input Monitoring manually: **System Settings › Privacy & Security › Input Monitoring → enable TangoDisplay**.

> If Input Monitoring is denied, hotkeys silently do nothing. All other features work normally.

---

## Next steps

- [Live View](Live-View) — understand the control window
- [Built-In Player](Built-In-Player) — set up the native setlist and audio player
- [Display Settings](Display-Settings) — choose your monitor and go fullscreen
- [Appearance](Appearance) — customise colors, fonts, and background
