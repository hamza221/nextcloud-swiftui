# ``NCNavigationItem``

## Overview

A sidebar row and nothing more. It draws an icon, a name, a count and an actions
menu, and it leaves everything about *being* a navigation control to the system.

### What `List` owns, and this view does not

| Behaviour | Where it comes from |
| --- | --- |
| Selection and the selected background | `List(selection:)` plus `.tag(_:)` |
| Hover highlight | `List` |
| Keyboard traversal, focus ring, type-select | `List` |
| Sidebar collapse, width, restoration | `NavigationSplitView` |
| Nesting and disclosure | `DisclosureGroup` |
| Reordering, drag and drop | `.onMove`, `.draggable` |

None of these have a parameter here. A row that carried its own `isSelected`
flag would fight the system for the highlight and lose the keyboard behaviour
that comes free with `List`.

```swift
NavigationSplitView {
    List(selection: $mailbox) {
        Section {
            ForEach(mailboxes) { mailbox in
                NCNavigationItem(mailbox.name, icon: .email, count: mailbox.unread)
                    .tag(mailbox.id)
            }
        } header: {
            NCNavigationCaption("Mailboxes")
        }
    }
    .listStyle(.sidebar)
} detail: {
    MessageList()
}
```

### Nesting

Wrap the row rather than extending it:

```swift
DisclosureGroup {
    ForEach(mailbox.children) { child in
        NCNavigationItem(child.name, icon: .folderOutline, count: child.unread).tag(child.id)
    }
} label: {
    NCNavigationItem(mailbox.name, icon: .folderOutline)
}
```

### The count

``NCCounterBubble``, not `.badge(_:)`. `.badge` does work inside a `List`, and
if a plain secondary-coloured number is what the screen wants, use it and skip
this component's `count` entirely. The bubble exists because Nextcloud draws a
tinted pill, which `.badge` cannot be made to do.

Zero draws nothing, so a row can pass its count unconditionally.

### Accessibility

The name carries the meaning, so the icon is decorative. The counter speaks
itself as an unread count. The actions menu has no text of its own and therefore
takes an ``NCAccessibilityLabel``, defaulting to "More actions"; pass something
more specific when the row's actions are not generic.

## Topics

### Related

- ``NCNavigationCaption``
- ``NCCounterBubble``
