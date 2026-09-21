# ``NCProfileCard``

## Overview

The large identity surface: an extra-large avatar, the display name, a few lines
about the person, and what you can do about them. It goes in a popover from an
``NCUserBubble``, or at the head of a contact detail pane.

```swift
NCProfileCard(
    displayName: "Lorelai Taylor",
    user: "lorelai",
    status: .online,
    secondaryLines: ["Product design", "lorelai@example.com", "Back on Monday"]
) {
    Button("Send message") { compose(to: "lorelai") }
}
```

### Why the detail lines are an array

Not `role:`, `email:` and `statusMessage:`. Every Nextcloud app shows a different
set, in a different order, and named slots turn an absent field into a decision
about vertical space at four call sites. An array closes the gap by itself.

They are caller data and are rendered verbatim -- a display name or an email
address must never pass through a localisation table. Blank entries are dropped
on the way in, so a caller can hand over an optional field without filtering it
first.

### Accessibility

The name and its detail lines combine into one element, with presence as its
accessibility value, so a reader hears the person once. The action slot stays
outside that element and remains individually reachable.
