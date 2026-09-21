# ``NCBreadcrumbs``

## Overview

The path trail above a Files-style browser, and the one component in the
navigation wave with no system equivalent. Finder's path bar is `NSPathControl`,
which is AppKit-only, addresses file URLs and cannot be themed, so none of it
carries over to a remote Nextcloud tree.

```swift
NCBreadcrumbs(path.map { NCBreadcrumbSegment(id: $0.path, title: $0.name) }) { segment in
    navigate(to: segment.id)
}
```

### Collapsing

When the trail is wider than the space it has, the middle folds into a menu and
the root and the current folder stay:

```
Files › Work › 2026 › Q3 › Reports
Files › … › Q3 › Reports
Files › … › Reports
```

Which segments fold is ``NCBreadcrumbCollapse/plan(segmentWidths:available:separatorWidth:overflowWidth:)``,
a plain function over measured widths that returns an ``NCBreadcrumbPlan``. The
view measures each label at its natural width behind the trail, asks for a plan,
and draws it. Keeping the rule out of `body` is what makes the awkward cases
testable: no segments, one segment, two segments that cannot both fit, and a
path whose every label is wider than the whole bar.

The rules, in order:

- Fewer than three segments never collapse. Collapsing two would hide the root
  or the leaf, and both ends of a path are worth more than a tidy width.
- If the whole trail fits, nothing collapses.
- Otherwise the root stays, and as many segments nearest the leaf as fit stay
  with it. Those are the steps a person is most likely to climb.
- If even the root, the menu and the leaf overflow, they are drawn anyway. Three
  truncated labels say more than an empty bar.

### Keyboard and pointer

Every segment is a `Button`, including the current folder, so the whole trail is
reachable by tab and by VoiceOver. Folded segments are reachable through the
menu, which is itself a keyboard-operable control. The link cursor is decoration
on top of that and never the only cue that a segment can be clicked.

### Right to left

The trail reverses with the layout direction and the chevrons mirror with it. A
breadcrumb that keeps pointing left to right in Arabic reads as a path running
backwards, which is why the RTL preview is the one to look at first after any
change here.

### What it does not do

Dropping files onto a crumb to move them, which `@nextcloud/vue` supports, is not
here. It needs a drop delegate per segment and a hit test that survives the
collapse, and no screen in the first clients needs it yet.

## Topics

### Describing a path

- ``NCBreadcrumbSegment``

### The collapse rule

- ``NCBreadcrumbCollapse``
- ``NCBreadcrumbPlan``
- ``NCBreadcrumbEntry``
