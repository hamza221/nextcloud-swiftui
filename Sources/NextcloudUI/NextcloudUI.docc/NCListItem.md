# ``NCListItem``

The workhorse row: a mailbox message, a conversation, a file, a share.

## Overview

A row is a leading slot, a title, an optional subtitle, an optional metadata
cluster and an optional trailing control. Put it in a `List` and give the `List`
a selection binding:

```swift
List(selection: $selectedMessage) {
    ForEach(messages) { message in
        NCListItem(message.sender, subtitle: message.subject) {
            NCIcon(.email, label: .decorative)
        } details: {
            NCListItemDetails(date: message.receivedAt, unreadCount: message.unread)
        }
    }
}
```

## Selection belongs to List

`NCListItem` draws no selection fill, no hover fill and no focus ring. `List`
already draws all three, tinted with the instance's brand colour through
`NCAccentPolicy`, and it brings the parts that are easy to forget: `⌘`-click
and `⇧`-click ranges, arrow-key traversal, the dimmed highlight when the window
resigns key, and a row that reports itself as selectable to VoiceOver.

A hand-rolled `background(isSelected ? ... : ...)` reproduces the fill and none
of the rest, and it is then wrong in every appearance Apple ships next.

There is no pointer cue either. macOS list rows do not change the cursor, and a
cue that only exists on hover is not an affordance on a device with no pointer.

## Truncation is fixed at one line

The title and the subtitle each truncate at one line, at the tail, and neither is
configurable.

A mailbox is scanned vertically. That only works when every row is the same
height, and uniform heights are also what let `List` estimate the size of ten
thousand messages without measuring them. A two-line subtitle turns a scroll bar
into a guess.

Tail truncation, rather than the middle truncation ``NCChip`` uses, because a
subject line and a preview snippet carry their meaning at the front. A chip holds
an e-mail address, which carries it at both ends.

Before any of that, text goes through ``NCListItemText/singleLine(_:)``. A Mail
preview is an HTML body with its tags stripped, so it arrives full of newlines,
and `lineLimit(1)` would keep the leading blank line and truncate the rest --
producing a row that looks like it failed to load.

## Marking a row unread

There is no `isUnread` parameter. The title sets no font weight, so the caller's
weight wins:

```swift
NCListItem(message.sender, subtitle: message.subject) { ... }
    .fontWeight(message.isRead ? nil : .semibold)
```

## Accessibility

The row combines into one element. VoiceOver reads "Lorelai Taylor, about
Friday, 2 minutes ago, 3 unread" and one swipe moves to the next message rather
than into the row.

`NCListItem` takes no `NCAccessibilityLabel`, because its title is text and
already conveys its meaning. The leading slot is what needs one, and
`NCAccessibilityLabel.decorative` is usually the honest answer: an avatar
beside the name it depicts says nothing new.

Combining makes a button in the trailing slot unreachable, so surface it the way
``NCChip`` surfaces its remove button -- as a rotor action on the row:

```swift
NCListItem(file.name) { NCIcon(.folderOutline, label: .decorative) }
    .accessibilityActions {
        Button(action: share) { Text(LocalizedStringResource(nc: "Share")) }
    }
```

## Topics

### Composing a row

- ``NCListItemDetails``
- ``NCListItemText``
