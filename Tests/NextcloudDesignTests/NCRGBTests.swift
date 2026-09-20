// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import Testing

@testable import NextcloudDesign

@Suite("NCRGB")
struct NCRGBTests {

    @Test(
        "parses the hex forms a server or a stylesheet can produce",
        arguments: [
            ("#00679e", "#00679e"),
            ("00679e", "#00679e"),
            ("#00679E", "#00679e"),  // case-insensitive
            ("#abc", "#aabbcc"),
            ("abc", "#aabbcc"),
            ("#000", "#000000"),
            ("#fff", "#ffffff"),
        ]
    )
    func parsesHex(_ input: String, _ expected: String) {
        #expect(NCRGB(hex: input)?.hexString == expected)
    }

    /// Brand colours arrive over the network. A malformed one must produce `nil`,
    /// never a trap: a misconfigured instance should not crash the client.
    @Test(
        "returns nil on malformed input rather than trapping",
        arguments: ["", "#", "#12", "#12345", "#1234567", "xyz", "#nothex", "  #00679e", "#0067 9e"]
    )
    func rejectsMalformedHex(_ input: String) {
        #expect(NCRGB(hex: input) == nil)
    }

    @Test("round-trips through hex")
    func roundTripsHex() {
        for packed: UInt32 in [0x0000_00, 0xFFFF_FF, 0x0067_9E, 0xB646_9D, 0x123456] {
            let colour = NCRGB(packed: packed)
            #expect(NCRGB(hex: colour.hexString) == colour)
        }
    }

    @Test("clamps components out of range")
    func clampsComponents() {
        #expect(NCRGB(red: -1, green: 2, blue: 0.5) == NCRGB(red: 0, green: 1, blue: 0.5))
        #expect(NCRGB(red8: -20, green8: 300, blue8: 128).hexString == "#00ff80")
    }

    @Test("blends in sRGB")
    func mixes() {
        let black = NCRGB.black
        #expect(black.mixed(with: .white, amount: 0) == black)
        #expect(black.mixed(with: .white, amount: 1) == .white)
        #expect(black.mixed(with: .white, amount: 0.5).hexString == "#808080")
        // The amount is clamped, so an out-of-range blend cannot overshoot.
        #expect(black.mixed(with: .white, amount: 5) == .white)
        #expect(black.mixed(with: .white, amount: -5) == black)
    }
}
