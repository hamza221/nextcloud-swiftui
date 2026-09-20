// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import Testing

@testable import NextcloudDesign

/// The highest-value test in the repository.
///
/// `usernameToColor` is the one function that is required to agree with
/// `@nextcloud/vue` exactly rather than approximately. A drift here is not a
/// rendering nit: the same colleague shows up teal in the browser and purple in
/// the Mail client, which reads as two different people.
@Suite("usernameToColor parity with @nextcloud/vue")
struct NCUsernameColorTests {

    @Test("reproduces every upstream snapshot vector", arguments: NCUsernameColorFixtures.all)
    func matchesUpstreamVector(_ vector: NCUsernameColorVector) {
        #expect(
            NCUsernameColor.rgb(for: vector.username).hexString == vector.hex,
            "usernameToColor(\(vector.username.debugDescription))"
        )
    }

    @Test("covers the full upstream fixture set")
    func fixtureCountIsIntact() {
        // Guards against a truncated re-import silently weakening the suite.
        #expect(NCUsernameColorFixtures.all.count == 36)
    }

    @Test("is stable across calls")
    func isDeterministic() {
        let first = NCUsernameColor.rgb(for: "Lorelai Taylor")
        let second = NCUsernameColor.rgb(for: "Lorelai Taylor")
        #expect(first == second)
    }

    @Test("ignores case, because the identifier is lowercased first")
    func isCaseInsensitive() {
        #expect(NCUsernameColor.rgb(for: "ADMIN") == NCUsernameColor.rgb(for: "admin"))
        #expect(NCUsernameColor.rgb(for: "Admin") == NCUsernameColor.rgb(for: "admin"))
    }

    @Test("hashes non-ASCII identifiers over their UTF-8 bytes")
    func handlesNonASCII() {
        // Both are upstream vectors; they are called out separately because a
        // port that hashed UTF-16 code units would still pass the ASCII cases.
        #expect(NCUsernameColor.rgb(for: "🙈").hexString == "#b6469d")
        #expect(NCUsernameColor.rgb(for: "مرحبا بالعالم").hexString == "#c98879")
    }

    @Test("always lands inside the palette")
    func alwaysIndexesInRange() {
        let palette = Set(NCAvatarPalette.standard)
        for candidate in ["", " ", "a", String(repeating: "z", count: 500), "🙈🙈🙈", "\u{0}"] {
            #expect(palette.contains(NCUsernameColor.rgb(for: candidate)))
        }
    }

    // MARK: The md5-shape skip

    @Test(
        "recognises identifiers that are already md5-shaped",
        arguments: [
            "123e4567-e89b-12d3-a456-426614174000",  // a federated cloud id
            "d41d8cd98f00b204e9800998ecf8427e",  // a bare md5
            "1234-5678-9abc-def0-1234-5678-9abc-def0",  // hyphen after every group
        ]
    )
    func detectsMD5Shape(_ identifier: String) {
        #expect(NCUsernameColor.hasMD5Shape(identifier))
    }

    @Test(
        "rejects identifiers that are not md5-shaped",
        arguments: [
            "",
            "admin",
            "123e4567-e89b-12d3-a456-42661417400",  // one digit short
            "123e4567-e89b-12d3-a456-4266141740000",  // one digit long
            "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",  // not hex
            "123E4567-E89B-12D3-A456-426614174000",  // uppercase: the class is [0-9a-f]
        ]
    )
    func rejectsNonMD5Shape(_ identifier: String) {
        #expect(!NCUsernameColor.hasMD5Shape(identifier))
    }

    @Test("skips re-hashing an md5-shaped identifier")
    func md5ShapedIdentifiersAreNotRehashed() {
        // Dropping this skip would recolour every federated contact relative to
        // the web client, so it is pinned explicitly rather than only implied by
        // the snapshot vector.
        let federated = "123e4567-e89b-12d3-a456-426614174000"
        let stripped = federated.filter { $0 != "-" }
        #expect(NCUsernameColor.hashCode(federated) == NCUsernameColor.hashCode(stripped))
    }
}

extension NCUsernameColorVector: CustomTestStringConvertible {
    var testDescription: String { "\(username.debugDescription) -> \(hex)" }
}
