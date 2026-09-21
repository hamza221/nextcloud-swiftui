// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import Testing

@testable import NextcloudUI

@Suite("Keyboard shortcut rendering")
struct NCKeyboardShortcutTests {

    /// Control, Option, Shift, Command. Every menu on the platform uses this
    /// order, so any other reads as a typo.
    @Test("orders modifiers canonically")
    func canonicalModifierOrder() {
        let all = NCKeyboardShortcutGlyphs.modifierGlyphs([.command, .shift, .option, .control])
        #expect(all == "\u{2303}\u{2325}\u{21E7}\u{2318}")
    }

    @Test("renders the common combinations")
    func rendersCombinations() {
        #expect(NCKeyboardShortcutGlyphs.string(for: NCKeyboardShortcut("k")) == "\u{2318}K")
        #expect(
            NCKeyboardShortcutGlyphs.string(for: NCKeyboardShortcut("k", modifiers: [.command, .shift]))
                == "\u{21E7}\u{2318}K"
        )
        #expect(NCKeyboardShortcutGlyphs.string(for: NCKeyboardShortcut("a", modifiers: [])) == "A")
    }

    @Test("upper-cases the key cap regardless of shift")
    func keyCapIsUppercased() {
        #expect(NCKeyboardShortcutGlyphs.keyGlyph("k") == "K")
        #expect(NCKeyboardShortcutGlyphs.keyGlyph("K") == "K")
        #expect(NCKeyboardShortcutGlyphs.keyGlyph("7") == "7")
    }

    @Test(
        "uses the standard glyph for named keys",
        arguments: [
            ("\r", "\u{21A9}"), ("\t", "\u{21E5}"), (" ", "\u{2423}"),
            ("\u{7F}", "\u{232B}"), ("\u{1B}", "\u{238B}"),
            ("\u{F700}", "\u{2191}"), ("\u{F701}", "\u{2193}"),
            ("\u{F702}", "\u{2190}"), ("\u{F703}", "\u{2192}"),
        ]
    )
    func namedKeyGlyphs(_ character: Character, _ expected: String) {
        #expect(NCKeyboardShortcutGlyphs.keyGlyph(character) == expected)
    }

    /// The named-key scalars must match what `KeyEquivalent`'s own cases carry,
    /// or a shortcut built from `.return` renders as a stray control character.
    @Test("agrees with KeyEquivalent's named cases")
    func agreesWithKeyEquivalent() {
        #expect(NCKeyboardShortcutGlyphs.keyGlyph(KeyEquivalent.return.character) == "\u{21A9}")
        #expect(NCKeyboardShortcutGlyphs.keyGlyph(KeyEquivalent.tab.character) == "\u{21E5}")
        #expect(NCKeyboardShortcutGlyphs.keyGlyph(KeyEquivalent.space.character) == "\u{2423}")
        #expect(NCKeyboardShortcutGlyphs.keyGlyph(KeyEquivalent.escape.character) == "\u{238B}")
        #expect(NCKeyboardShortcutGlyphs.keyGlyph(KeyEquivalent.delete.character) == "\u{232B}")
        #expect(NCKeyboardShortcutGlyphs.keyGlyph(KeyEquivalent.upArrow.character) == "\u{2191}")
        #expect(NCKeyboardShortcutGlyphs.keyGlyph(KeyEquivalent.downArrow.character) == "\u{2193}")
        #expect(NCKeyboardShortcutGlyphs.keyGlyph(KeyEquivalent.leftArrow.character) == "\u{2190}")
        #expect(NCKeyboardShortcutGlyphs.keyGlyph(KeyEquivalent.rightArrow.character) == "\u{2192}")
    }

    /// The glyphs are punctuation to a screen reader, so the spoken form is not
    /// optional.
    @Test("spells the combination out for assistive technology")
    func spokenDescription() {
        let shortcut = NCKeyboardShortcut("k", modifiers: [.command, .shift])
        #expect(NCKeyboardShortcutGlyphs.accessibilityDescription(for: shortcut) == "Shift Command K")
    }

    @Test("round-trips through KeyEquivalent")
    func roundTripsKeyEquivalent() {
        let shortcut = NCKeyboardShortcut(KeyEquivalent.return, modifiers: [.command])
        #expect(shortcut.character == KeyEquivalent.return.character)
        #expect(shortcut.keyEquivalent.character == KeyEquivalent.return.character)
    }

    @Test("is usable as a dictionary key")
    func isHashable() {
        let a = NCKeyboardShortcut("k", modifiers: [.command, .shift])
        let b = NCKeyboardShortcut("k", modifiers: [.shift, .command])
        let c = NCKeyboardShortcut("k", modifiers: [.command])
        #expect(a == b)
        #expect(a != c)
        #expect(Set([a, b, c]).count == 2)
    }
}
