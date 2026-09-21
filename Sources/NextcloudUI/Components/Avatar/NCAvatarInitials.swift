// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

/// The letters an avatar falls back to when there is no photo.
///
/// Separated from the view because this is where the edge cases live and none of
/// them need SwiftUI: a name that is one word, a name that is five, a name that
/// is empty, a name in a script with no case, and a name that starts with an
/// emoji. What remains in ``NCAvatar`` is composition.
public nonisolated enum NCAvatarInitials {
    /// The initials for a display name: the first letter or digit of the first
    /// word, plus the same from the last word when there is more than one.
    ///
    /// Returns an empty string when the name has no letter or digit anywhere --
    /// a name that is only an emoji, only punctuation, or blank. The caller draws
    /// a person icon instead, which is better than a box or a stray accent.
    ///
    /// Words are taken whole, so a grapheme cluster such as a flag or a
    /// skin-toned emoji is never split into its scalars.
    public static func initials(for displayName: String) -> String {
        let letters =
            displayName
            .split(whereSeparator: \.isWhitespace)
            .compactMap { word in word.first { $0.isLetter || $0.isNumber } }
        guard let first = letters.first, let last = letters.last else { return "" }
        // Two words give two letters; "Jean Paul van der Berg" gives "JB", which
        // is what a reader scanning a list expects to see.
        let picked = letters.count > 1 ? [first, last] : [first]
        // A no-op in scripts without case, which is why it is not conditional.
        return String(picked).uppercased()
    }
}
