<!--
SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# New library strings, wave 2

For merging into `Sources/NextcloudUI/Resources/Localizable.xcstrings`.

**None.** Wave 2 adds no library-owned string.

Every word the identity components put on screen is caller data -- a display
name, an email address, a status message -- and caller data stays a `String` and
never goes through a table. Running it through one is how a person called
"Cancel" gets renamed.

The two places that could have needed a string do not:

- `NCAvatar` and `NCUserBubble` speak presence through
  `NCUserStatus.accessibilityLabel`, whose six keys wave 1 already added, and
  they attach it as an accessibility *value* rather than splicing it into the
  label. That avoids a `"%1$@, %2$@"` join key, which translators cannot do
  anything useful with anyway.
- `NCAsyncImage` shows the caller's own placeholder on failure rather than a
  library-owned error message.
