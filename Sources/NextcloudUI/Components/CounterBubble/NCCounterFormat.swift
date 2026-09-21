// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import Foundation

/// The text a counter shows, separated from the view that draws it.
///
/// Pulling this out is not test theatre. Capping, locale-aware grouping and the
/// zero case are the parts that actually have edge cases, and none of them need
/// SwiftUI to exercise. What remains in `NCCounterBubble.body` is composition
/// that genuinely does not need a test.
public nonisolated enum NCCounterFormat {
    /// The default cap. Above this the exact number stops being useful and the
    /// bubble starts driving the row's layout.
    public static let defaultLimit = 99

    /// The text for a count.
    ///
    /// - Parameters:
    ///   - count: The raw count. Negative values are treated as zero.
    ///   - limit: The largest number shown exactly. Above it, `"99+"`.
    ///   - locale: Used for digit grouping, so a German build reads `1.234`.
    public static func text(
        for count: Int,
        limit: Int = defaultLimit,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let clamped = max(count, 0)
        guard limit > 0 else { return format(clamped, locale: locale) }
        if clamped > limit {
            return format(limit, locale: locale) + "+"
        }
        return format(clamped, locale: locale)
    }

    /// Whether a count should render at all.
    ///
    /// Zero is not a badge. A row showing "0" reads as a broken badge rather than
    /// as an empty mailbox.
    public static func isVisible(_ count: Int) -> Bool { count > 0 }

    private static func format(_ value: Int, locale: Locale) -> String {
        value.formatted(.number.grouping(.automatic).locale(locale))
    }
}
