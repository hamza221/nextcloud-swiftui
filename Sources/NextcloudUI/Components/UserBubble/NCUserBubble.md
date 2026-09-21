# ``NCUserBubble``

## Overview

The mention affordance: what `@lorelai` renders as in a comment, a recipient
field or an activity line.

```swift
NCUserBubble(displayName: "Lorelai Taylor", user: "lorelai", action: { openProfile() })
```

It defaults to ``NCAvatar/Size/small``, which is the size that sits in a line of
text without changing its leading.

### One element, not two

A mention is one thing. The avatar is passed
``NCAccessibilityLabel/decorative`` and the row is combined, so VoiceOver reads
the name once rather than hearing it from the avatar and then again from the
label -- which is what makes a long recipient list unbearable. Presence rides
along as the element's accessibility value.

`action` makes the whole capsule activatable and adds a link pointer. Omit it for
a bubble that only labels; a `Button` wrapper is not added around something with
nothing to do.

### Slots

`trailing` takes whatever follows the name, usually a remove control or a
counter. The constrained convenience initialiser covers the common case, so no
call site writes `trailing: { EmptyView() }`.
