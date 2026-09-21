# Empty states

Why this package ships no `NCEmptyContent`.

## Overview

`NcEmptyContent` is `ContentUnavailableView`. The roadmap already said so, and
the work of wave 3 was to check whether a thin Nextcloud-flavoured wrapper over
it earns its keep. It does not, so there is no such type. Use the system view:

```swift
ContentUnavailableView(
    "No messages",
    systemImage: "tray",
    description: Text("Messages you receive appear here.")
)
```

and for search, which is most of the empty states a Nextcloud client shows:

```swift
ContentUnavailableView.search(text: query)
```

## What a wrapper would have added, and why none of it survives

A wrapper would have taken an ``NCSymbol`` and applied theme tokens. Taken
apart, that is three claims, and all three fail.

**The symbol.** ``NCIcon`` sizes from `theme.metrics.icon`, whose largest step is
20pt, because those are sizes for a row and a toolbar. `ContentUnavailableView`
draws its glyph far larger than that and scales it with the container and with
Dynamic Type. Passing it a fixed 20pt `NCIcon` replaces correct behaviour with a
tiny mark and a `// ponytail:` comment. Sizing it properly means inventing an
empty-state step in ``NCMetrics`` that exists for one caller.

**The tokens.** There are none to apply. An empty state is a title, a
description and a glyph, drawn in `.primary` and `.secondary` on the window
background -- exactly the system semantics ``NCColorTokens`` deliberately does
not duplicate, for the reason set out there. The only Nextcloud-specific colour
that could appear is the brand tint on an action button, and `.ncTheme(_:)`
already sets `.tint` app-wide, so a `Button(...).buttonStyle(.borderedProminent)`
inside the system view is already branded without a wrapper.

**The strings.** `ContentUnavailableView.search` ships translated into every
language Apple supports. A wrapper's equivalent would go through
`LocalizedStringResource(nc:)` and wait on the Transifex pipeline that the
roadmap defers, so it would be English-only in every locale where the system
view is already correct.

What is left is a type that renames `ContentUnavailableView`, costs a line in
every call site's mental model, and takes behaviour away. Per the README's
"Native macOS first": Nextcloud identity arrives through colour tokens, icons and
domain views. An empty state is none of those. It is a system view with the app's
own words in it.

## When to revisit

If Nextcloud design specifies an illustration rather than a glyph -- the web
client uses one in a few places -- that is a real difference and a wrapper earns
itself at that point. It would take an `Image`, not an ``NCSymbol``, and it would
still delegate the layout to `ContentUnavailableView`.
