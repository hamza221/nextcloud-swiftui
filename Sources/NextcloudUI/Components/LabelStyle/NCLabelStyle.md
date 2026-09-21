# ``NCLabelStyle``

Nextcloud's icon-and-text pairing, and the icon-only variant that keeps a
toolbar usable.

## Overview

```swift
Label {
    Text(verbatim: mailbox.name)
} icon: {
    NCIcon(.email, label: .decorative)
}
.labelStyle(.nc)
```

``NCLabelStyle/Layout/standard`` is an `HStack` at
`theme.metrics.spacing.tight`, centre-aligned. That is the whole layout.
SwiftUI's default label already puts the icon first, aligns it optically with
the text and inherits the foreground style. The one thing it does not know is
Nextcloud's gap, and that gap is why this exists.

Centre alignment rather than first-baseline: every label in this library pairs a
glyph with one line of text, and a baseline match sits the icon visibly low.

## The icon-only variant is the accessible one

``NCLabelStyle/Layout/iconOnly`` is the system `IconOnlyLabelStyle` plus a
minimum hit target from `NCPlatformMetrics`, which differs between macOS and iOS.

The system style is the point. It hides the title visually and keeps it as the
label's spoken name, so a toolbar of nothing but glyphs stays navigable on
VoiceOver. A bare ``NCIcon`` in a `Button` does not, and there is no way for the
reader to recover what the button does.

```swift
Button(action: archive) {
    Label {
        Text(LocalizedStringResource(nc: "Archive"))
    } icon: {
        NCIcon(.folderOutline, label: .decorative)
    }
}
.labelStyle(.ncIconOnly)
```

The icon inside takes ``NCAccessibilityLabel/decorative``. The title beside it is
the answer, and hearing it twice is how a toolbar becomes unbearable.

``NCButtonStyle/Role/icon`` applies `.ncIconOnly` for you, so an icon button
needs only `.buttonStyle(.icon)`.

## Why the shorthand is `ncIconOnly`

`LabelStyle` already has an `iconOnly` member. Adding another with the same name
in a constrained extension would make `.labelStyle(.iconOnly)` at an existing
call site resolve to a different type, silently, on the next build. The prefix is
a deliberate wart in exchange for that not happening.

``NCLabelStyle/Layout/standard`` has no such clash, so its shorthand is `.nc`.

## What is not here

No title-only layout: `.titleOnly` is a system style already and needs no
Nextcloud gap.

No stacked icon-above-title layout: that belongs to an empty state, which is
`ContentUnavailableView`.

## Topics

### Layouts

- ``NCLabelStyle/Layout``

### Related

- ``NCButtonStyle``
- ``NCIcon``
