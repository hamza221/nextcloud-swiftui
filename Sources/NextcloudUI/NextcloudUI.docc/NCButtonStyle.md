# ``NCButtonStyle``

Nextcloud's button roles, each one a system button style with a token tint.

## Overview

```swift
HStack {
    Button(action: send) { Text(LocalizedStringResource(nc: "Send")) }
        .buttonStyle(.primary)
    Button(action: dismiss) { Text(LocalizedStringResource(nc: "Cancel")) }
        .buttonStyle(.tertiary)
}
```

Five roles, and each one is a single system style plus a tint:

| Role | Built on | Tint |
| --- | --- | --- |
| ``NCButtonStyle/Role/primary`` | `.borderedProminent` | brand |
| ``NCButtonStyle/Role/secondary`` | `.bordered` | brand |
| ``NCButtonStyle/Role/tertiary`` | `.plain` | brand, as the foreground |
| ``NCButtonStyle/Role/error`` | `.borderedProminent` | error token |
| ``NCButtonStyle/Role/icon`` | `.bordered`, icon-only | brand |

That table is the entire component. There is no custom shape, no fill, no press
animation and no focus ring anywhere in it.

## Why not a custom rectangle

A rounded rectangle filled with the brand colour looks right in a screenshot and
wrong in a toolbar. It has to reimplement, and then keep reimplementing:

- the press response, and the way it differs between a click and a spacebar
- the disabled appearance
- the keyboard focus ring, at the width the system is currently drawing
- the dimming when the window resigns key
- the Reduce Transparency behaviour, where every control beside it changes and a
  hand-painted fill does not
- whatever Liquid Glass does next

None of that is worth owning to control a corner radius. What the system cannot
know is the colour the server reported for this instance, so that is what the
style supplies.

## The tint is not always the brand

`NCAccentPolicy.instance`, the default, already installs the brand as `.tint`
app-wide through `.ncTheme(_:)`. Under that policy a primary button is
brand-tinted with no style at all, and the explicit tint here is a no-op.

The style earns its place under the other two policies:

- `NCAccentPolicy.brandSurfacesOnly` leaves ordinary controls on the user's
  macOS accent. A primary action is a brand surface, so it is tinted here.
- `NCAccentPolicy.system` tints nothing. The style passes a `nil` tint, and the
  button keeps the user's accent.

``NCButtonStyle/Role/error`` ignores the policy entirely. An error colour is a
status token rather than branding, and a destructive action is the same red on
every instance.

## `Role` and `ButtonRole` do different jobs

``NCButtonStyle/Role/error`` colours a button. `Button(role: .destructive)` tells
the system what the button *means*, which decides where it sorts in a menu, how
an alert emphasises it, and what a confirmation dialog does with it.

They are orthogonal. A delete button wants both, and this style forwards the
`ButtonRole` it is handed:

```swift
Button(role: .destructive, action: delete) {
    Text(LocalizedStringResource(nc: "Delete"))
}
.buttonStyle(.error)
```

## Sizing

There is no `size` parameter. `.controlSize(.large)` is the system spelling and
it already affects every style here. A full-width button is
`.frame(maxWidth: .infinity)` on the `Button`, not a `wide:` argument.

## Accessibility

A button with visible text needs nothing extra. An icon button does, and the
answer is ``NCLabelStyle``: pass a `Label` whose title is the action's name, and
``NCButtonStyle/Role/icon`` hides the title visually while the system keeps it as
the spoken name.

```swift
Button(action: archive) {
    Label {
        Text(LocalizedStringResource(nc: "Archive"))
    } icon: {
        NCIcon(.folderOutline, label: .decorative)
    }
}
.buttonStyle(.icon)
```

The icon inside takes `NCAccessibilityLabel.decorative`, because the title is
already the answer.

## Topics

### Roles

- ``NCButtonStyle/Role``

## See Also

- ``NCLabelStyle``
