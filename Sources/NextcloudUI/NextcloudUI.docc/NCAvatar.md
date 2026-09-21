# ``NCAvatar``

## Overview

```swift
NCAvatar(displayName: "Lorelai Taylor", user: "lorelai", status: .online) {
    try await client.avatar(for: "lorelai", size: 64)
}
```

### The fallback chain

Photo, then initials on a generated colour, then a person icon. The middle step
carries the component. Most Nextcloud accounts have no photo, and a column of
identical grey circles makes a message list unreadable, so the colour is doing
the work that a photo would.

The colour comes from ``NCUsernameColor``, which is pinned against the web
client's vectors. A colleague who is teal in the browser is teal here, and a
drift would read as two different people. The foreground is picked with
``NCContrast`` rather than fixed to white, because the palette runs from gold to
deep purple and white fails contrast across a third of it.

The initials themselves come from ``NCAvatarInitials``, which is a plain enum
with no SwiftUI in it. One-word names, five-word names, scripts without case,
emoji-leading names and empty strings are settled there and tested there.

### Identity

`user` is the account id and `displayName` is the label. When both are present
the colour and the cache key come from `user`, so a person keeps their colour
when they change their name. When `user` is absent, `displayName` seeds both.

### Sizes

Four, resolved against `theme.metrics.avatar`: 20, 32, 44 and 64pt as macOS
values. Nothing here is a literal, so an instance that ships a denser metric
scale resizes every avatar in the app at once.

Initials use a semantic font per size rather than a size computed from the
diameter, so they follow Dynamic Type, with `minimumScaleFactor` keeping them
inside the circle at the largest accessibility sizes.

### Accessibility

The avatar is one element labelled with the display name, with presence as its
accessibility value. It never reads as "image, Lorelai Taylor, online status
indicator".

`label` defaults to the display name because the component already holds a
correct answer, which is the same reason ``NCUserStatusBadge`` defaults to the
status name. Pass ``NCAccessibilityLabel/decorative`` when the name is visible
beside it, as ``NCUserBubble`` and ``NCProfileCard`` both do.

## Topics

### Deriving initials

- ``NCAvatarInitials``
