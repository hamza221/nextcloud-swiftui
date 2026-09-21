<!--
SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# New library strings, wave 5

For merging into `Sources/NextcloudUI/Resources/Localizable.xcstrings`. Three
keys. Everything else the input components draw is caller data (a display name,
an address, an emoji) or is written by the system.

| Key | Comment | Used by |
| --- | --- | --- |
| `Search people` | Label and placeholder for the field that filters the candidate list in the people picker. | `NCUserPicker` |
| `Add reaction` | Accessibility label for the button that opens the emoji menu under a message. | `NCReactionPicker` |
| `More reactions…` | Menu item that opens the system emoji palette. Keep the ellipsis: macOS convention marks a command that opens further UI. | `NCReactionPicker` |

As catalogue entries:

```json
"Add reaction" : {
  "comment" : "Accessibility label for the button that opens the emoji menu under a message.",
  "extractionState" : "manual"
},
"More reactions…" : {
  "comment" : "Menu item that opens the system emoji palette. Keep the ellipsis: macOS convention marks a command that opens further UI.",
  "extractionState" : "manual"
},
"Search people" : {
  "comment" : "Label and placeholder for the field that filters the candidate list in the people picker.",
  "extractionState" : "manual"
}
```

## What deliberately has no string

`NCUserPicker`'s empty state is `ContentUnavailableView.search(text:)`, which the
system writes and translates. Adding "No results" here would ship a second,
worse translation of a sentence macOS already has in every locale.

`NCButtonStyle`, `NCLabelStyle` and `NCProgressStyle` add no strings at all. A
style colours and arranges what the caller passes; every word in a button, a
label or a progress bar comes from the app.

`NCReactionPicker.defaultFrequent` is six emoji and is not a string table entry.
An emoji means the same thing in every language, and running it through a
localisation table would let a translator change what the web client and the
native client put in the same slot.
