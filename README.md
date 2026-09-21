<!--
SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# NextcloudUI

A SwiftUI component library for native Nextcloud clients on Apple platforms.

Nextcloud's web apps share [`@nextcloud/vue`][ncvue], which gives every app the
same shell, controls and identity. Nothing equivalent existed for native Apple
development. This is that layer: design tokens plus the views that encode
Nextcloud domain concepts.

**This is not a port.** Most of `@nextcloud/vue` should not be rebuilt, because
SwiftUI on macOS 26 already provides it, or because the problem it solves only
exists in a browser. Of the 100 components upstream, roughly 35 are already
SwiftUI (`NcButton` is a `Button` plus a `ButtonStyle`; the eight app-shell
components collapse into `NavigationSplitView` plus `.inspector`) and roughly 20
solve problems that evaporate outside a browser. What remains is a token layer
and about 26 views.

## Status

Early. The foundation is in place; most components are not yet built.

| | |
| --- | --- |
| **Built** | Design tokens, theme, brand derivation, contrast maths, `usernameToColor`, the platform layer, the icon catalogue, wave 1 atoms |
| **Next** | Wave 2 identity (`NCAvatar`, `NCAsyncImage`), wave 3 lists (`NCListItem`) |
| **Not started** | Navigation, input, the showcase app, DocC articles |

See [`docs/ROADMAP.md`](docs/ROADMAP.md) for the full plan and what is
deliberately deferred.

## Requirements

macOS 26, Swift 6.2. No back-deployment shims. The code is kept structurally
multiplatform-clean so that iOS can be added later at an incremental cost rather
than a rewrite — CI measures this on every pull request.

## Installation

```swift
.package(url: "https://github.com/hamza221/nextcloud-swiftui", branch: "main")
```

```swift
.target(name: "MyApp", dependencies: [
    .product(name: "NextcloudUI", package: "nextcloud-swiftui"),
])
```

`NextcloudUI` re-exports `NextcloudDesign` and `NextcloudIcons`, so one import
is enough.

## Usage

Install a theme once, near the root of a `Scene`:

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

Re-theme when the server's capabilities call returns. One assignment recolours
the running app:

```swift
if let brand = NCBrand(primaryHex: capabilities.theming.color) {
    theme = NCTheme(brand: brand)
}
```

Tokens are `ShapeStyle`s, so they go anywhere SwiftUI takes a style — and no
component ever reads `\.colorScheme`:

```swift
Text(name).foregroundStyle(theme.colors.favorite)
Circle().fill(theme.colors.primary)
```

## Design decisions

A few that are load-bearing, and the reasoning rather than just the rule:

**Native macOS first.** System controls, system materials, Apple HIG focus and
keyboard behaviour. Nextcloud identity arrives through colour tokens, icons and
domain views — not through reimplemented controls. `NCButtonStyle.primary` is
`.borderedProminent` with the brand tint, not a custom flat rectangle: the
system does the glass, the token supplies the hue. A hand-painted button looks
visibly foreign beside system controls in the same toolbar, with the wrong press
response and the wrong behaviour under Reduce Transparency.

**macOS metrics win.** The 4px grid baseline, the 34px clickable area and the
15px body text are not ported. Dynamic Type supplies text sizing.

**~180 CSS custom properties collapse to ~40 tokens.** Anything macOS provides
semantically — window and control backgrounds, the text and separator
hierarchies, placeholders, scrollbars, shadows — is deliberately absent. A token
that duplicates a system semantic will look wrong the first time Apple changes
the system appearance, which on a platform where Liquid Glass has just landed is
a live risk.

**The brand colour tints globally.** `.ncTheme(_:)` sets `.tint`, so an
instance's colour drives list selection and focus rings as well as avatars and
chips. This overrides the user's chosen macOS accent, which is deliberate. An app
that disagrees can set `NCAccentPolicy.brandSurfacesOnly` or `.system` without a
library change.

**No networking, ever.** The package is pure presentation: no auth, no server
client, no `URLSession`. `AsyncImage` is banned by a lint rule, because it uses
`URLSession.shared` internally — which would put networking inside a package
declared network-free, and would bypass the app's authenticated session.
Nextcloud avatar endpoints need auth, so `AsyncImage` returns 401 on every
private instance. Components take an `@Sendable () async throws -> Image` loader
instead.

**Accessibility is required API.** Upstream's `ariaLabel` is an optional prop,
which means it gets skipped. Here, `NCAccessibilityLabel` is a non-optional
argument, so unlabelled construction is impossible — the author has to choose,
even if the choice is `.decorative`.

## Parity with the web client

One thing must agree with `@nextcloud/vue` exactly rather than approximately:
`usernameToColor`. It picks a person's avatar colour from a hash of their
identifier, and a drift means the same colleague shows up teal in the browser and
purple in the Mail client — which reads as two different people.

All 36 vectors from the upstream Vitest snapshot are imported verbatim and
pinned as a test, including the md5-shape skip that keeps federated cloud ids
colouring consistently:

```sh
Scripts/import-username-color-fixtures.py /path/to/nextcloud-vue
```

## Development

```sh
make setup     # install the git hooks
make build
make test
make lint      # formatting, design-system invariants, platform discipline
```

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Licence

AGPL-3.0-or-later, matching `@nextcloud/vue`. The repository is
[REUSE][reuse]-compliant; every file carries an SPDX header or is covered by a
glob in `REUSE.toml`.

[ncvue]: https://github.com/nextcloud-libraries/nextcloud-vue
[reuse]: https://reuse.software
