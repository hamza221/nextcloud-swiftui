# ``NextcloudUI``

SwiftUI components for native Nextcloud clients.

## Overview

`NextcloudUI` re-exports `NextcloudDesign` and `NextcloudIcons`, so one import
is enough:

```swift
import NextcloudUI
```

New here? Read <doc:GettingStarted>. Coming from `@nextcloud/vue`? Read
<doc:MigratingFromNextcloudVue> first: most of what you are looking for is
already a system API, and the table says which one.

### Three modules, three archives

`@_exported import` gives a consumer one import line, but it does not merge
symbol graphs, and DocC builds one archive per module. So a link from here to
`NCTheme` or `NCIcon` would not resolve, and every reference to a
`NextcloudDesign` or `NextcloudIcons` symbol in this archive is written in plain
code voice rather than as a link. Their own archives carry their reference
documentation:

```sh
NC_BUILD_DOCS=1 swift package generate-documentation --target NextcloudDesign
NC_BUILD_DOCS=1 swift package generate-documentation --target NextcloudIcons
```

`make docs` builds all three.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:MigratingFromNextcloudVue>

### Identity

- ``NCAvatar``
- ``NCUserBubble``
- ``NCProfileCard``
- ``NCUserStatus``
- ``NCUserStatusBadge``

### Lists and rows

- ``NCListItem``
- <doc:EmptyStates>

### Navigation

- ``NCNavigationItem``
- ``NCNavigationCaption``
- ``NCBreadcrumbs``
- <doc:SettingsSections>

### Picking people, and reacting

- ``NCUserPicker``
- ``NCReactionPicker``

### Styles

- ``NCButtonStyle``
- ``NCLabelStyle``
- ``NCProgressStyle``

### Atoms

- ``NCChip``
- ``NCCounterBubble``
- ``NCNoteCard``
- ``NCHighlightText``
- ``NCKeyboardShortcutLabel``
- ``NCRelativeDateText``

### Images

- ``NCAsyncImage``

### Logic with no SwiftUI in it

Every non-trivial view here delegates to a plain value type that is testable
without rendering anything. The rest are curated under the component they serve.

- ``NCCounterFormat``
- ``NCHighlight``
- ``NCKeyboardShortcut``
- ``NCKeyboardShortcutGlyphs``
