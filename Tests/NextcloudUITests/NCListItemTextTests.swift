// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing

@testable import NextcloudUI

@Suite("Single-line row text")
struct NCListItemTextTests {

    @Test("keeps clean text unchanged")
    func cleanText() {
        #expect(NCListItemText.singleLine("About Friday") == "About Friday")
        #expect(NCListItemText.singleLine("Re: deployment window") == "Re: deployment window")
    }

    @Test("treats nothing to show as absent", arguments: [nil, "", " ", "\t", "\n\n", "  \n \t "])
    func blankIsAbsent(_ value: String?) {
        #expect(NCListItemText.singleLine(value) == nil)
    }

    /// A stripped HTML mail body. With `lineLimit(1)` and no flattening the row
    /// shows the leading empty line and looks like it failed to load.
    @Test("flattens a stripped mail body onto one line")
    func flattensMailBody() {
        let body = "\n  Hi Lorelai,\n\n  about Friday\n"
        #expect(NCListItemText.singleLine(body) == "Hi Lorelai, about Friday")
    }

    @Test("trims the ends and collapses runs")
    func trimsAndCollapses() {
        #expect(NCListItemText.singleLine("  About   Friday  ") == "About Friday")
        #expect(NCListItemText.singleLine("a\t\tb") == "a b")
    }

    /// Web-sourced text is full of non-breaking spaces, which are whitespace to
    /// Unicode but not to a naive `" "` split.
    @Test("collapses a non-breaking space like any other")
    func nonBreakingSpace() {
        #expect(NCListItemText.singleLine("Jean\u{00A0}Dupont") == "Jean Dupont")
        #expect(NCListItemText.singleLine("\u{00A0}") == nil)
    }

    /// Only whitespace is touched. A zero-width joiner holds a family emoji
    /// together and must survive.
    @Test("leaves zero-width joiners alone")
    func zeroWidthJoiner() {
        let family = "\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}"
        #expect(NCListItemText.singleLine(family) == family)
    }

    @Test("leaves right-to-left text alone")
    func rightToLeft() {
        #expect(NCListItemText.singleLine("  بخصوص يوم الجمعة ") == "بخصوص يوم الجمعة")
    }
}
