# Display Settings

The **Display** tab controls which monitor receives the dancer display, fullscreen behaviour, and what text labels appear.

![Display settings](https://raw.githubusercontent.com/richardsladetdj-creator/TangoDisplay/main/docs/screenshots/display-settings.png)

---

## Monitor

| Control | Description |
|---|---|
| **Target display** | Drop-down list of all connected monitors. Select the screen you want dancers to see. |
| **Move Presentation Window** | Moves the dancer display window to the selected monitor. Note: this is not possible while fullscreen is active. |
| **Toggle Fullscreen** | Puts the presentation window into fullscreen mode (or exits it). Fullscreen creates a new macOS Space — use Mission Control if you need to navigate. |

**Workflow:** Select your monitor from the drop-down, click **Move Presentation Window**, then click **Toggle Fullscreen**.

---

## Control Window

| Option | Description |
|---|---|
| **Mirror mode** | When on, the control window shows a live preview of what is on the dancer display. Turn off to save CPU if you don't need the preview. |
| **Show track counter (Track X of X)** | Controls whether the "Track X of X" position indicator appears on the dancer display. |
| **Position** | Where the track counter appears: **Top left**, **Top right**, **Bottom left**, **Bottom right** (default), or **Centred (in text order)**. Disabled when Show track counter is off. When set to "Centred (in text order)", the counter renders as part of the text stack and its position within that stack can be adjusted via Appearance > Visibility > Text Order for Dance Tracks. |

---

## Display Labels

These are the text strings shown on the dancer display for special states. Edit the fields directly.

| Label | When shown | Default |
|---|---|---|
| **Cortina** | Displayed prominently when a cortina is detected | `CORTINA` |
| **Coming up** | Shown before the next tanda starts (with genre and artist) | `COMING UP` |
| **Idle message** | Displayed when nothing is playing in Music.app | *(empty)* |

Leave **Idle message** empty to show a blank screen when music is stopped. Enter a message (e.g. "Back soon…") to display something instead.

### DJ Name

| Control | Description |
|---|---|
| **Show TDJ Name** | Master switch — enables the DJ name overlay on the dancer display |
| **TDJ Name** | The text to display (edit the field, then click **Save**) |
| **Position** | Where the name appears: **Top left**, **Top right**, **Bottom left** (default), **Bottom right**, or **Centred (in text order)**. When set to Centred, the name renders as part of the text stack — adjust its position in Appearance > Visibility > Text Order for Dance Tracks. |
| **Show when** | **Any track playing** — name visible only while a track is playing · **Idle / Paused** — name visible only when idle or paused · **Always** — name always visible |

Click **Save** to apply name text changes.
