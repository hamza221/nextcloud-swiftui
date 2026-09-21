<!--
SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# New library strings, wave 4

For merging into `Sources/NextcloudUI/Resources/Localizable.xcstrings`. Two keys,
both accessibility labels for controls that carry an icon and no text. Everything
else the navigation components draw is caller data and stays a `String`.

| Key | Comment | Used by |
| --- | --- | --- |
| `More actions` | Accessibility label for the trailing actions menu on a sidebar navigation row. | `NCNavigationItem` |
| `Show hidden path components` | Accessibility label for the overflow menu that holds the breadcrumb segments which did not fit. | `NCBreadcrumbs` |

As catalogue entries:

```json
"More actions" : {
  "comment" : "Accessibility label for the trailing actions menu on a sidebar navigation row.",
  "extractionState" : "manual"
},
"Show hidden path components" : {
  "comment" : "Accessibility label for the overflow menu that holds the breadcrumb segments which did not fit.",
  "extractionState" : "manual"
}
```

`NCNavigationItem`'s counter reuses the existing `%lld unread` key through
``NCCounterBubble``, so wave 4 adds nothing there.
