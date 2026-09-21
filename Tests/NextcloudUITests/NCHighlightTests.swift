// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import Testing

@testable import NextcloudUI

@Suite("Search highlighting")
struct NCHighlightTests {

    private func matched(_ text: String, _ query: String) -> [String] {
        NCHighlight.ranges(in: text, matching: query).map { String(text[$0]) }
    }

    @Test("finds every occurrence")
    func findsAllOccurrences() {
        #expect(matched("banana", "an") == ["an", "an"])
        #expect(matched("Mail, mailbox, MAILING", "mail") == ["Mail", "mail", "MAIL"])
    }

    @Test("ignores case")
    func ignoresCase() {
        #expect(matched("Lorelai Taylor", "LORELAI") == ["Lorelai"])
    }

    /// Someone searching a contact list types "Mortel", not "Mörtel".
    @Test("ignores diacritics")
    func ignoresDiacritics() {
        #expect(matched("Tom Mörtel", "mortel") == ["Mörtel"])
        #expect(matched("Tom Mortel", "mörtel") == ["Mortel"])
    }

    /// This is what makes highlight-as-you-type usable before the first
    /// character is typed: an empty query must match nothing, not everything.
    @Test("matches nothing for an empty or blank query", arguments: ["", " ", "\t", "\n  "])
    func emptyQueryMatchesNothing(_ query: String) {
        #expect(NCHighlight.ranges(in: "anything at all", matching: query).isEmpty)
    }

    @Test("matches nothing in an empty subject")
    func emptySubjectMatchesNothing() {
        #expect(NCHighlight.ranges(in: "", matching: "a").isEmpty)
    }

    @Test("does not overlap matches")
    func matchesDoNotOverlap() {
        // "aa" in "aaa" is one match, not two: the second would start inside the
        // first.
        #expect(matched("aaa", "aa").count == 1)
    }

    @Test("matches nothing when the query is longer than the subject")
    func queryLongerThanSubject() {
        #expect(NCHighlight.ranges(in: "ab", matching: "abcdef").isEmpty)
    }

    @Test("trims surrounding whitespace from the query")
    func trimsQuery() {
        #expect(matched("Lillian Wall", "  wall  ") == ["Wall"])
    }

    @Test("handles non-ASCII subjects without slicing a grapheme")
    func handlesNonASCII() {
        #expect(matched("مرحبا بالعالم", "بالعالم") == ["بالعالم"])
        #expect(NCHighlight.ranges(in: "🙈 hidden", matching: "hidden").count == 1)
    }

    @Test("produces an attributed string covering the matches")
    func producesAttributedString() {
        let attributed = NCHighlight.attributed("banana", matching: "an", background: .yellow)
        #expect(String(attributed.characters) == "banana")
        // Both matches in "banana" are adjacent, so AttributedString coalesces
        // them into a single run. Count the covered characters instead.
        let covered = attributed.runs
            .filter { $0.backgroundColor != nil }
            .reduce(0) { $0 + attributed[$1.range].characters.count }
        #expect(covered == 4)
    }

    @Test("returns the subject unchanged when nothing matches")
    func noMatchLeavesTextUnchanged() {
        let attributed = NCHighlight.attributed("banana", matching: "zz", background: .yellow)
        #expect(String(attributed.characters) == "banana")
        #expect(attributed.runs.allSatisfy { $0.backgroundColor == nil })
    }
}
