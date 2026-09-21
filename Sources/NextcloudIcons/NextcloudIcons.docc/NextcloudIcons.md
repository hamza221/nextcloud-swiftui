# ``NextcloudIcons``

The Material Design Icon catalogue Nextcloud draws from.

## Overview

`NextcloudUI` re-exports this module, so an app that imports `NextcloudUI` has it
already. It is a separate target because resources are the one thing the linker
cannot dead-strip, and an app that never renders an icon should not pay for the
asset catalogue.

``NCSymbol`` names a glyph. ``NCIcon`` draws one, at a size from
`theme.metrics.icon` and in whatever `.foregroundStyle` is in effect — an icon
never picks its own colour. Its accessibility label is a required argument, and
`NCAccessibilityLabel.decorative` is the right answer whenever the text beside it
already carries the meaning.

A symbol that has no generated asset falls back to its SF Symbols equivalent, and
one with neither renders as a conspicuous missing-glyph mark rather than as a
blank gap nobody notices until a screenshot review.

## Topics

### Drawing an icon

- ``NCIcon``

### Naming a glyph

- ``NCSymbol``
