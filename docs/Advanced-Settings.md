# Advanced Settings

TangoDisplay includes optional regex-based transformations for displayed track metadata.

This allows advanced users to customise how Artist, Title, Year, Album Artist, and Comments appear on the display screen — without modifying the original music tags.

---

## Enabling Transformations

1. Click the display icon in the menu bar › **Show Settings Window**
2. Go to **Advanced** in the sidebar

The Advanced Settings panel shows a table with one row for each field that can be transformed.

---

## The Field Table

Each row shows the field name, whether a transformation is currently enabled, and a live preview of how the transformation will change the value. Click any row to expand the editor panel below the table.

---

## The Editor Panel

When a row is selected, the editor panel shows:

| Control | Description |
|---|---|
| **Enable** toggle | Turns the transformation on or off for this field |
| **Pattern** | The regex pattern to match against the field value |
| **Replace with** | The replacement template. Use `$1`, `$2` etc. to insert capture groups from the pattern. Use `\n` for a line break (also `\r`, `\t`, and `\\` for a literal backslash) |
| **Test input** | A sample value to test your pattern against — edit this to try different inputs |
| **Result** | The live transformed output, updated as you type |

### Status indicators

- **Green checkmark** — the pattern matched and the transformation was applied successfully
- **Yellow warning** — the pattern did not match the test input; the original value will be shown unchanged
- **Red error** — the pattern is not valid regex; fix the pattern before saving

Click **Reset to default** to clear the pattern, replacement, and test input for the selected field.

---

## Example use cases

### Remove additional artist information after a slash

Some libraries store variant information after a slash in the Artist field (e.g. `Any Artist Name / Type`). This rule strips everything from the slash onwards, leaving only the primary name.

**Input:**
```
Any Artist Name / Type
```

**Pattern:**
```
^(.?)\s/\s*.*$
```

**Replace with:**
```
$1
```

**Output:**
```
Any Artist Name
```

---

### Remove recording speed or extra information from track titles

Tracks tagged with technical notes in the title (e.g. `Any Track Name - 440 hz`) can have that suffix removed cleanly.

**Input:**
```
Any Track Name - 440 hz
```

**Pattern:**
```
^(.?)\s-\s*.*$
```

**Replace with:**
```
$1
```

**Output:**
```
Any Track Name
```

---

### Split a combined field across two lines

If your library tags artist and title together in a single field (e.g. `Carlos Di Sarli - Verdemar`) you can capture each part and put them on separate lines on the dancer display using `\n` in the replacement.

**Input:**
```
Carlos Di Sarli - Verdemar
```

**Pattern:**
```
^(.+?)\s-\s(.+)$
```

**Replace with:**
```
$1\n$2
```

**Output:**
```
Carlos Di Sarli
Verdemar
```

---

## Notes

- Transformations are **optional** and **per-field** — you can enable them for Artist only, or for any combination of fields.
- Transformations are applied **on display only** — your original music tags are never modified.
- The live preview updates instantly as you type; no save step is required.
- A **Reset All** button at the bottom of the panel clears every transformation after a confirmation prompt.
