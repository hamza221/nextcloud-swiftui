# ``NCNavigationCaption``

## Overview

`Section(header:)` already groups rows, pins the heading while the sidebar
scrolls, and collapses with the sidebar. This view is the part left over: the
Nextcloud heading weight, the vertical spacing token, the header accessibility
trait, and a control on the heading's trailing edge.

Use it *as* a section header. It is not a replacement for `Section`:

```swift
Section {
    ForEach(calendars) { calendar in
        NCNavigationItem(calendar.name, icon: .calendarAccountOutline).tag(calendar.id)
    }
} header: {
    NCNavigationCaption("Calendars") {
        Button { addCalendar() } label: {
            NCIcon(.plus, label: .text("Add calendar"))
        }
        .buttonStyle(.plain)
    }
}
```

Without a trailing control, the delta over `Section(header: Text(name))` is the
weight and the spacing alone. That is small enough that using the plain `Text`
header is a reasonable choice, and it is the right one when a screen only has one
section.

### What it deliberately leaves out

A collapsible section is `DisclosureGroup`, which animates, remembers its state
and is keyboard-operable already. A count beside a heading has not come up in a
real screen, so there is no `count:` parameter to keep in sync with the rows
below it.

### Accessibility

The header trait sits on the text rather than on the row, so the trailing control
stays a separate element that VoiceOver and the keyboard can reach.

## See Also

- ``NCNavigationItem``
