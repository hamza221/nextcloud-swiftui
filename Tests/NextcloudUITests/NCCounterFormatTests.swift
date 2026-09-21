// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing

@testable import NextcloudUI

@Suite("Counter formatting")
struct NCCounterFormatTests {
    private let posix = Locale(identifier: "en_US_POSIX")

    @Test("shows small counts exactly", arguments: [(1, "1"), (9, "9"), (42, "42"), (99, "99")])
    func exactCounts(_ count: Int, _ expected: String) {
        #expect(NCCounterFormat.text(for: count, locale: posix) == expected)
    }

    @Test("caps above the limit")
    func capsAboveLimit() {
        #expect(NCCounterFormat.text(for: 100, locale: posix) == "99+")
        #expect(NCCounterFormat.text(for: 5000, locale: posix) == "99+")
        #expect(NCCounterFormat.text(for: 1000, limit: 999, locale: posix) == "999+")
    }

    @Test("treats the limit itself as exact, not capped")
    func limitIsInclusive() {
        #expect(NCCounterFormat.text(for: 99, limit: 99, locale: posix) == "99")
        #expect(NCCounterFormat.text(for: 100, limit: 99, locale: posix) == "99+")
    }

    /// A row showing "0" reads as a broken badge rather than as an empty mailbox.
    @Test("hides a zero count entirely")
    func zeroIsHidden() {
        #expect(!NCCounterFormat.isVisible(0))
        #expect(NCCounterFormat.isVisible(1))
    }

    @Test("clamps a negative count rather than rendering a minus sign")
    func negativeIsClamped() {
        #expect(!NCCounterFormat.isVisible(-1))
        #expect(NCCounterFormat.text(for: -5, locale: posix) == "0")
    }

    @Test("groups digits for the locale")
    func groupsDigits() {
        // German groups with a full stop, so a cap-free large count must not read
        // as "1234".
        let german = NCCounterFormat.text(for: 1234, limit: 0, locale: Locale(identifier: "de_DE"))
        #expect(german.contains("1") && german.contains("234"))
        let american = Locale(identifier: "en_US")
        #expect(NCCounterFormat.text(for: 1234, limit: 0, locale: american) == "1,234")
        // en_US_POSIX has no grouping separator at all.
        #expect(NCCounterFormat.text(for: 1234, limit: 0, locale: posix) == "1234")
    }
}
