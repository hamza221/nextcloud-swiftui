// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import Foundation
public import SwiftUI

/// Marking search matches inside a string.
///
/// The matching itself is a pure function over strings, which is where all the
/// edge cases live: an empty query, a query longer than the subject, overlapping
/// candidates, and the diacritic folding that makes searching "Mortel" find
/// "Mörtel". None of it needs SwiftUI to test.
public nonisolated enum NCHighlight {

    /// Every match of `query` in `text`.
    ///
    /// Matching is case- and diacritic-insensitive, because a person typing into
    /// a search field is not thinking about either. Matches do not overlap:
    /// searching `"aa"` in `"aaa"` yields one range, not two.
    ///
    /// An empty or whitespace-only query yields no ranges rather than matching
    /// everything, which is what makes "highlight as you type" usable before the
    /// first character is typed.
    public static func ranges(in text: String, matching query: String) -> [Range<String.Index>] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty, !text.isEmpty else { return [] }

        var found: [Range<String.Index>] = []
        var searchStart = text.startIndex

        while searchStart < text.endIndex,
            let match = text.range(
                of: needle,
                options: [.caseInsensitive, .diacriticInsensitive],
                range: searchStart..<text.endIndex
            )
        {
            found.append(match)
            // A zero-width match would not advance; step past it defensively so
            // this can never spin.
            searchStart = match.isEmpty ? text.index(after: match.lowerBound) : match.upperBound
        }
        return found
    }

    /// `text` with every match of `query` styled.
    ///
    /// - Parameters:
    ///   - text: The subject.
    ///   - query: What the user typed.
    ///   - background: Applied behind each match.
    ///   - foreground: Applied to each match, or `nil` to inherit.
    public static func attributed(
        _ text: String,
        matching query: String,
        background: Color,
        foreground: Color? = nil
    ) -> AttributedString {
        var attributed = AttributedString(text)
        for range in ranges(in: text, matching: query) {
            guard let lower = AttributedString.Index(range.lowerBound, within: attributed),
                let upper = AttributedString.Index(range.upperBound, within: attributed)
            else { continue }
            attributed[lower..<upper].backgroundColor = background
            if let foreground {
                attributed[lower..<upper].foregroundColor = foreground
            }
        }
        return attributed
    }
}

/// Text with search matches marked.
///
/// ```swift
/// NCHighlightText(contact.displayName, matching: searchQuery)
/// ```
public struct NCHighlightText: View {
    private let text: String
    private let query: String

    @Environment(\.ncTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    public init(_ text: String, matching query: String) {
        self.text = text
        self.query = query
    }

    public var body: some View {
        // One of the very few places a component resolves a token to a concrete
        // Color: AttributedString attributes are values, not styles, so there is
        // no ShapeStyle to hand them.
        Text(
            NCHighlight.attributed(
                text,
                matching: query,
                background: theme.colors.highlight.color(for: colorScheme)
            )
        )
    }
}
