<!--
SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# New library strings, wave 3

None.

Nothing in `NCListItem` or `NCListItemDetails` needs a key in
`Sources/NextcloudUI/Resources/Localizable.xcstrings`, so the orchestrator has
nothing to merge from this wave.

## Why there are none

A row is made of caller data. The title, the subtitle and the leading slot's
contents are a sender, a subject and an avatar: all `String`, all passed through
`Text(verbatim:)`, and none of them may go through a localisation table. Running
user data through one is how a person called "Cancel" gets renamed.

The two strings a row does speak are already owned by wave 1 and wave 0, and are
reused rather than restated:

| String | Owner | Used by |
| --- | --- | --- |
| `"\(count) unread"` | `NCCounterBubble` (`Localizable.xcstrings`) | `NCListItemDetails`, through the counter it composes |
| the relative-time phrases | `NCRelativeDateFormatter` (`NextcloudDesign/Resources/Localizable.xcstrings`) | `NCListItemDetails`, through `NCRelativeDateText` |

`NCEmptyContent` was not built, so it contributes no strings either. See
`Sources/NextcloudUI/NextcloudUI.docc/EmptyStates.md` for that decision:
`ContentUnavailableView.search` is already translated into every language Apple
ships, which is one of the reasons not to wrap it.
