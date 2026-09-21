# Getting started

Add the package, install a theme, and hand every image a loader.

## Overview

Four things are worth reading before the first component goes on screen. Two of
them are conventions this package will not let you skip: the theme, and the
image loader closure.

## Add the package

```swift
.package(url: "https://github.com/hamza221/nextcloud-swiftui", branch: "main")
```

```swift
.target(name: "MyApp", dependencies: [
    .product(name: "NextcloudUI", package: "nextcloud-swiftui"),
])
```

`NextcloudUI` re-exports `NextcloudDesign` and `NextcloudIcons`, so `import
NextcloudUI` is the only import a file needs. macOS 26 and Swift 6.2, with no
back-deployment shims.

## Install a theme

Every component reads its colours, spacing, motion and font weights from one
`NCTheme` in the environment. Install it once, near the root of a `Scene`:

```swift
import NextcloudUI

@main
struct MailApp: App {
    @State private var theme = NCTheme.nextcloud

    var body: some Scene {
        WindowGroup {
            ContentView()
                .ncTheme(theme)
        }
    }
}
```

There is a default, so a view renders correctly in a preview or a test with no
theme installed. What the default cannot know is the server's brand colour, which
arrives with the capabilities response. Re-assign the theme and the running app
recolours:

```swift
if let brand = NCBrand(primaryHex: capabilities.theming.color) {
    theme = NCTheme(brand: brand)
}
```

`NCBrand(primaryHex:)` returns `nil` on malformed input rather than trapping,
because that string comes off the network and a misconfigured instance must not
crash the client.

Tokens conform to `ShapeStyle`, so they go wherever SwiftUI takes a style, and no
component ever reads `\.colorScheme` to choose between a light and a dark value:

```swift
Text(name).foregroundStyle(theme.colors.favorite)
Circle().fill(theme.colors.primary)
```

Read the theme in your own views the same way the components do:

```swift
@Environment(\.ncTheme) private var theme
```

## Decide the accent policy

`.ncTheme(_:)` also sets SwiftUI's `.tint`, which means the instance's brand
colour drives list selection, focus rings and the default button as well as the
avatars and chips that read the token directly. That overrides the user's chosen
macOS accent colour, and it is the default on purpose: a Nextcloud client is
expected to look like the instance it is connected to.

An app that disagrees says so through `NCAccentPolicy`, without a change to this
library:

```swift
NCTheme(brand: brand, base: NCTheme(accentPolicy: .brandSurfacesOnly))
```

- `.instance` is the default. The brand tints everything.
- `.brandSurfacesOnly` keeps the user's macOS accent on ordinary controls, and
  puts the brand only on Nextcloud surfaces: avatars, chips, status, primary
  actions.
- `.system` uses the brand as a token but never as a tint.

`NCButtonStyle` and `NCProgressStyle` both honour the policy. Their error and
warning roles do not, because a status colour is not branding and a destructive
action is red on every instance.

## Hand every image a loader

This package does no networking. It has no credentials, no `URLSession` and no
knowledge of your authenticated session, and a Nextcloud avatar endpoint answers
401 without one. So an image is not a URL here. It is a closure:

```swift
NCAvatar(displayName: person.displayName, user: person.id) {
    try await client.avatar(for: person.id)   // returns a SwiftUI Image
}
```

The signature is `@Sendable () async throws -> Image` everywhere it appears, on
``NCAsyncImage``, ``NCAvatar``, ``NCUserBubble``, ``NCProfileCard`` and
``NCUserPicker``. It runs on a task that is cancelled when the view goes away,
and its result is cached by ``NCImageCache`` under the identity you supply.

Three consequences worth knowing up front:

- The loader is optional on every avatar-shaped view. Omit it and the person's
  initials appear on a colour derived from their account id, which matches the
  web client exactly. Most Nextcloud accounts have no photo, so this is the
  common path rather than the fallback.
- A failed load renders the placeholder, the same as a pending one. There is no
  failure slot and no retry, because the placeholder — initials on a generated
  colour — is already the right thing to show when a photo never arrives.
- `AsyncImage` is banned by a lint rule. It uses `URLSession.shared` internally,
  which would put networking inside a package declared network-free and would
  bypass your session.

Decode with `NCImageDecoder` from `NextcloudPlatform` if you want downsampling
straight to the target size rather than a 2000px bitmap on its way to a 32pt
avatar.

## Label anything that is not text

`NCAccessibilityLabel` is a non-optional argument on every view whose meaning is
not already carried by visible text. `@nextcloud/vue` makes `ariaLabel` optional,
which means it gets skipped; here unlabelled construction does not compile. The
choice can still be "nothing to say":

```swift
NCIcon(.email, label: .decorative)                 // the row's title says it
NCIcon(.email, label: .text("Inbox"))              // a translated library string
NCAvatar(displayName: name, label: .content(name)) // runtime data, never a table
```

`.decorative` is correct far more often than it looks, because a row that reads
as one element should not also announce its icon.

## Two things that are deliberately not components

Some of `@nextcloud/vue` is better served by a system view than by a wrapper, and
saying so is part of the API. Two of those decisions have their own pages, with
the reasoning and the replacement code:

- <doc:EmptyStates> — why there is no `NCEmptyContent`, and what
  `ContentUnavailableView` does instead.
- <doc:SettingsSections> — why there is no `NCSettingsSection`, and what `Form`
  and `Section` do instead.

<doc:MigratingFromNextcloudVue> is the same judgement applied to all hundred-odd
upstream components at once.

## See Also

- <doc:MigratingFromNextcloudVue>
- <doc:EmptyStates>
- <doc:SettingsSections>
