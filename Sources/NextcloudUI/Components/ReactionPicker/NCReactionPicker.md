# ``NCReactionPicker``

Talk's reaction row: the emoji already on a message, plus a way to add one.

## Overview

```swift
NCReactionPicker(message.reactions) { emoji in
    Task { try await client.react(to: message.id, with: emoji) }
}
```

A row of pills and an add button. Each pill is an ``NCChip`` inside a `Button`,
carrying the emoji and its count; tapping one adds this account's reaction or
takes it away. Past `visibleLimit` the remaining reactions move into the add
button's menu, so the row never pushes a message off its own width.

The view holds no state. `onToggle` hands the emoji back and the caller returns a
new ``NCReactionSummary``, which means an optimistic update and a rollback after
a failed request are both expressible without fighting the component for
ownership.

## Counts are not in this file

Toggling, the zero case and the ordering are in ``NCReactionSummary``, which has
no SwiftUI in it:

- taking away the last reaction of a kind removes the pill rather than leaving a
  zero behind
- an emoji nobody has used yet appears with a count of one, already marked as
  this account's
- the server's list is sorted by count, and ties keep the order they arrived in,
  so every client shows the same row
- ``NCReactionSummary/toggling(_:)`` does *not* re-sort. Sorting on each tap
  would move the pill out from under the pointer mid-click, which reads as a
  misfire even when the toggle worked

## The emoji picker is the system's

macOS ships one: search, skin-tone variants, recents, every Unicode category,
and `⌃⌘Space` opens it everywhere else on the machine. A grid of our own would be
a worse copy that goes stale with each Unicode release, so "More reactions…"
opens the `NCEmojiPalette` shim in `NextcloudPlatform`.

There is one wrinkle. `orderFrontCharacterPalette` *inserts* into the focused
responder and returns nothing, so there is no value to read back. This view
therefore keeps a one-character field, focuses it before opening the palette, and
reads what lands in it. That field is the only platform-specific thing in the
component, and the AppKit call behind it lives in `NextcloudPlatform`, which is
the only target permitted to import AppKit.

On a platform with no palette, `NCEmojiPalette.isAvailable` is `false`, the
menu item is absent and the catcher field is never built, so nothing offers an
affordance that would do nothing.

## Accessibility

A pill is emoji plus a number, which is text, so it needs no
``NCAccessibilityLabel``. What it does need is the *state*: a pill this account
is part of carries the `isSelected` trait, so VoiceOver says "selected" rather
than leaving that to a tint colour nobody can hear.

The add button is a glyph with no text and takes a label accordingly.

## Frequent reactions

``NCReactionPicker/defaultFrequent`` matches the six the web client offers, in
the same order, so the same emoji is in the same place in both clients. It is
neither localised nor themed: an emoji means the same thing in every language.

Pass your own `frequent:` when a deployment has different conventions.

## Topics

### The model

- ``NCReaction``
- ``NCReactionSummary``

### Composed from

- ``NCChip``
