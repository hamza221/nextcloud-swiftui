# ``NextcloudDesign``

The token layer: colour, metrics, motion, type, and the colour maths behind them.

## Overview

`NextcloudUI` re-exports this module, so an app that imports `NextcloudUI` has it
already. It is a separate target because it is the portability canary: it
contains no platform code at all, compiles for every Apple platform with no
conditionals, and that is enforced in CI.

Roughly 180 CSS custom properties upstream collapse to about 40 tokens here.
Anything macOS already provides semantically — window and control backgrounds,
the text and separator hierarchies, placeholders, scrollbars, shadows — is
deliberately absent, because a token that duplicates a system semantic looks
wrong the first time Apple changes the system appearance.

Everything lives in one ``NCTheme`` rather than in forty environment keys. That
buys one environment read per view, one assignment to re-theme a running app, and
a value that is trivial to build in a test.

## Topics

### The theme

- ``NCTheme``
- ``NCAccentPolicy``

### Branding

- ``NCBrand``
- ``NCColorSchemeVariant``

### Colour tokens

- ``NCColorTokens``
- ``NCStatusColors``
- ``NCUserStatusColors``
- ``NCDynamicColor``
- ``NCDynamicGradient``
- ``NCGradientStop``
- ``NCAssistantColors``

### Metrics, motion and type

- ``NCMetrics``
- ``NCSpacingScale``
- ``NCRadiusScale``
- ``NCIconScale``
- ``NCAvatarScale``
- ``NCMotion``
- ``NCTypography``

### Colour maths

The part that has to agree with the server and with the web client exactly,
rather than approximately.

- ``NCRGB``
- ``NCContrast``
- ``NCUsernameColor``
- ``NCAvatarPalette``

### Dates

- ``NCRelativeDateFormatter``
- ``NCRelativeDateSchedule``

### Accessibility

- ``NCAccessibilityLabel``

### Previews

- ``NCThemePreviewModifier``
