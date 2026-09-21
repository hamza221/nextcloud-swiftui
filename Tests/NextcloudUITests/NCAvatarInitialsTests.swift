// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import Testing

@testable import NextcloudUI

@Suite("Avatar initials")
struct NCAvatarInitialsTests {
    @Test(
        "takes the first and last word",
        arguments: [
            ("Lorelai Taylor", "LT"),
            ("Jean Paul van der Berg", "JB"),
            ("  Zaki   Cortes  ", "ZC"),
        ]
    )
    func firstAndLast(_ name: String, _ expected: String) {
        #expect(NCAvatarInitials.initials(for: name) == expected)
    }

    @Test("gives one letter for a one-word name", arguments: [("Cher", "C"), ("admin", "A")])
    func oneWord(_ name: String, _ expected: String) {
        #expect(NCAvatarInitials.initials(for: name) == expected)
    }

    /// The avatar draws a person icon when there is nothing to draw, which is
    /// the whole reason this returns an empty string rather than a placeholder
    /// letter.
    @Test("gives nothing for a name with no letters", arguments: ["", "   ", "🎉", "!!!", "…"])
    func nothingToDraw(_ name: String) {
        #expect(NCAvatarInitials.initials(for: name).isEmpty)
    }

    @Test("skips a leading emoji rather than drawing half of it")
    func emojiLeading() {
        #expect(NCAvatarInitials.initials(for: "🎉 party time") == "PT")
        #expect(NCAvatarInitials.initials(for: "🇩🇪 Tom Mörtel") == "TM")
        // A skin-toned emoji is several scalars in one grapheme cluster. Taking
        // it apart is how an avatar ends up showing a bare modifier.
        #expect(NCAvatarInitials.initials(for: "👩🏽‍💻 Ada") == "A")
    }

    @Test("leaves scripts without case alone")
    func nonLatin() {
        #expect(NCAvatarInitials.initials(for: "田中 太郎") == "田太")
        #expect(NCAvatarInitials.initials(for: "محمد علي") == "مع")
        #expect(NCAvatarInitials.initials(for: "Дарья Петрова") == "ДП")
    }

    @Test("reaches past punctuation to the first real character")
    func punctuation() {
        #expect(NCAvatarInitials.initials(for: "(deleted user)") == "DU")
        #expect(NCAvatarInitials.initials(for: "@lorelai") == "L")
    }

    @Test("counts a digit as a letter, because account ids are full of them")
    func digits() {
        #expect(NCAvatarInitials.initials(for: "42 Team") == "4T")
    }
}
