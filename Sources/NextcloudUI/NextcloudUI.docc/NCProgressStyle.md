# ``NCProgressStyle``

Nextcloud's determinate bar: an upload, a sync, a background job.

## Overview

```swift
ProgressView(value: upload.sent, total: upload.size) {
    Text(verbatim: upload.filename)
} currentValueLabel: {
    Text(upload.sent, format: .byteCount(style: .file))
}
.progressViewStyle(.normal)
```

The style is `.linear` with a tint. That is the whole implementation, and it is
the correct amount.

## What `.linear` already does

Everything except the colour:

- the track, the fill and the rounded ends
- the title above the bar and the current-value label below it
- the animation between two values, and the Reduce Motion response
- the indeterminate sweep when no value is bound
- the percentage VoiceOver reads, without being asked

Drawing the bar by hand would buy control of the track height and cost all of the
above. The height is not worth it.

## Roles

``NCProgressStyle/Role/normal`` follows `NCAccentPolicy` the way
``NCButtonStyle`` does: brand-tinted, unless the app asked for the user's macOS
accent with `NCAccentPolicy.system`.

``NCProgressStyle/Role/warning`` and ``NCProgressStyle/Role/error`` are status
tokens and ignore the policy, so a stalled sync is amber and a failed upload is
red on every instance, branded or not.

A role is colour and nothing else. It does not pause the bar, and it does not say
what went wrong, so a failed upload still needs its own text:

```swift
ProgressView(value: upload.sent, total: upload.size) {
    Text(LocalizedStringResource(nc: "Upload failed"))
}
.progressViewStyle(.error)
```

Colour alone is not a message, and roughly one man in twelve cannot read this
particular one.

## What is not here

No circular variant: `.circular` is already the right style for a spinner.

No track-height parameter: a custom height means drawing the bar, which loses the
system's Reduce Transparency and Reduce Motion behaviour.

## Topics

### Roles

- ``NCProgressStyle/Role``

## See Also

- ``NCButtonStyle``
