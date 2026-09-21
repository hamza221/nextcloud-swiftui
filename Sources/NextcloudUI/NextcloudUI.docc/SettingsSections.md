# Building a settings pane

Why this library ships no `NCSettingsSection`, and what to write instead.

## Overview

Wave 4 was planned with four components. Three shipped. `NCSettingsSection` did
not, because after measuring it against macOS 26 there was nothing left in it.

`NcAppSettingsSection` exists upstream because the web has no grouped-form
control. A browser gives you a `<fieldset>` and a stylesheet, so
`@nextcloud/vue` has to draw the group, the heading, the row separators, the
inset and the spacing itself. macOS draws all of that:

```swift
Settings {
    Form {
        Section("General") {
            Toggle("Show unread badge", isOn: $showsBadge)
            Picker("Default calendar", selection: $calendar) { … }
        }
        Section {
            Toggle("Send read receipts", isOn: $readReceipts)
        } header: {
            Text("Privacy")
        } footer: {
            Text("Read receipts tell the sender when you opened their message.")
        }
    }
    .formStyle(.grouped)
}
```

That is the grouped background, the heading typography, the footer, the row
separators, the label column alignment, the inset, the toolbar, the window size
and its restoration. A component wrapping it could only add a name.

### What a wrapper would have cost

Anything drawn here instead of by `Form` stops matching System Settings the first
time Apple adjusts grouped-form metrics, which on a release where Liquid Glass is
still settling is a live risk, not a theoretical one. It is the same reasoning
that keeps window and control backgrounds out of `NCColorTokens`.

### Where the Nextcloud identity goes

Nothing about a settings pane is Nextcloud-specific except its contents, and the
contents are already covered:

- ``NCNoteCard`` for an explanation or a warning inside a section.
- ``NCChip`` for a selected tag, folder or recipient in a row.
- ``NCKeyboardShortcutLabel`` for a shortcut in a row's trailing position.
- `.ncTheme(_:)` at the `Scene`, which tints every control in the pane with the
  instance's brand colour.

### If the delta ever stops being zero

Two things could bring this component back. Both are worth waiting for a real
screen rather than guessing at:

- A section that needs a trailing control on its heading, the way
  ``NCNavigationCaption`` does. `Form` takes an arbitrary `header:` view, so
  that may still need nothing new.
- A settings row with an avatar, a status and a subtitle, which is
  `NCListItem`'s problem rather than a section's.
