# ``NextcloudUI``

SwiftUI components for native Nextcloud clients.

## Overview

`NextcloudUI` re-exports ``NextcloudDesign`` and ``NextcloudIcons``, so one
import is enough:

```swift
import NextcloudUI
```

Install a theme once, near the root of a `Scene`, and re-assign it when the
server's capabilities call returns:

```swift
ContentView().ncTheme(NCTheme(brand: brand))
```

Tokens conform to `ShapeStyle`, so they go anywhere SwiftUI takes a style — and
no component ever needs to read `\.colorScheme` to pick a light or dark value.

## Topics

### Theming

- ``NCTheme``
- ``NCBrand``
- ``NCAccentPolicy``
- ``NCColorTokens``
- ``NCDynamicColor``

### Accessibility

- ``NCAccessibilityLabel``

### Identity

- ``NCUsernameColor``
- ``NCAvatarPalette``
- ``NCUserStatus``
- ``NCUserStatusBadge``

### Atoms

- ``NCIcon``
- ``NCCounterBubble``
- ``NCChip``
- ``NCNoteCard``
- ``NCHighlightText``
- ``NCKeyboardShortcutLabel``
- ``NCRelativeDateText``

### Formatting

- ``NCCounterFormat``
- ``NCHighlight``
- ``NCRelativeDateFormatter``
- ``NCKeyboardShortcutGlyphs``
