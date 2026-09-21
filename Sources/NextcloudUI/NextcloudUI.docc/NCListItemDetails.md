# ``NCListItemDetails``

The trailing metadata cluster of a row: when it happened, over how much of it is
unread.

## Overview

```swift
NCListItem(message.sender, subtitle: message.subject) {
    NCIcon(.email, label: .decorative)
} details: {
    NCListItemDetails(date: message.receivedAt, unreadCount: message.unread)
}
```

Mail and Talk stack exactly this arrangement, so it is one view rather than two
call sites that have to keep agreeing on spacing and alignment. It is a separate
component rather than two parameters on ``NCListItem`` so that a row with
different metadata -- a file size, a share expiry -- passes its own view into the
same slot.

## Both halves disappear on their own

A `nil` date draws no timestamp. A zero count draws no bubble, because
``NCCounterFormat/isVisible(_:)`` hides it: a row showing "0" reads as a broken
badge, not as an empty mailbox. With neither, the cluster is zero-sized, so a
read conversation with no timestamp leaves no gap where it would have been.

The cluster is `fixedSize` horizontally. The subject line gets the slack, which
is the right trade: a truncated subject is still scannable, a truncated
timestamp is not.

## The default formatter

`NCRelativeDateFormatter(width: .short, ignoresSeconds: true)`. Abbreviated
because a row is narrow, and second-free because a counter ticking once a second
pulls the eye off the subject line -- the same reason `@nextcloud/vue` turns it
off in list contexts.

Refresh cadence comes from `NCRelativeDateSchedule`, which relaxes as the date
ages. A mailbox of ten thousand messages does not wake once a second.

## Accessibility

"2 min. ago" is fine to read and poor to hear, so the timestamp is spoken in the
long form while it is drawn in the short one. The count carries its own label
from ``NCCounterBubble``.

Inside an ``NCListItem`` both fold into the row's combined element, so VoiceOver
hears them as part of one sentence rather than as two more stops.
