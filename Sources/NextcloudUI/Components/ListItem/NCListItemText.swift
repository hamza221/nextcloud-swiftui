// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

/// Preparing caller data for a single-line row, separated from the view that
/// draws it.
///
/// This exists because real row data is not clean. A Mail preview snippet is an
/// HTML body with its tags stripped, so it arrives as
/// `"\n  Hi Lorelai,\n\n  about Friday\n"`. A `Text` with `lineLimit(1)` keeps
/// the first line and truncates, so the row shows an empty subtitle and reads as
/// a loading bug. A file name pasted from a terminal carries a trailing tab. A
/// display name from LDAP can be nothing but spaces.
///
/// Those are the parts with edge cases, and none of them need SwiftUI to
/// exercise.
public nonisolated enum NCListItemText {

    /// `value` flattened onto one line, or `nil` when nothing is left to show.
    ///
    /// Every run of whitespace collapses to a single space, and leading and
    /// trailing whitespace goes. That includes the non-breaking space, which
    /// web-sourced text is full of. A string that is only whitespace returns
    /// `nil`, which is what stops a row reserving a subtitle line for nothing.
    ///
    /// Only whitespace is touched. Zero-width joiners survive, so a family emoji
    /// stays one glyph instead of becoming four.
    public static func singleLine(_ value: String?) -> String? {
        guard let value else { return nil }
        let words = value.split(whereSeparator: \.isWhitespace)
        return words.isEmpty ? nil : words.joined(separator: " ")
    }
}
