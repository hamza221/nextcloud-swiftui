// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import Testing

@testable import NextcloudDesign

@Suite("WCAG contrast maths")
struct NCContrastTests {

    @Test("puts black and white at the defined extreme of 21:1")
    func extremeRatio() {
        #expect(abs(NCContrast.ratio(.white, .black) - 21) < 0.001)
    }

    @Test("puts a colour against itself at 1:1")
    func identityRatio() {
        #expect(abs(NCContrast.ratio(.white, .white) - 1) < 0.000_001)
        #expect(abs(NCContrast.ratio(NCRGB(packed: 0x0067_9E), NCRGB(packed: 0x0067_9E)) - 1) < 0.000_001)
    }

    @Test("is symmetric")
    func isSymmetric() {
        let a = NCRGB(packed: 0x0067_9E)
        let b = NCRGB(packed: 0xFFF0_C7)
        #expect(NCContrast.ratio(a, b) == NCContrast.ratio(b, a))
    }

    /// `#767676` on white is the canonical worked example of the AA boundary: it
    /// is the darkest grey that still fails to clear 4.5 comfortably, landing at
    /// 4.54. A port that skipped gamma linearisation lands near 3.9 and would
    /// pass every other assertion here.
    @Test("linearises channels before weighting them")
    func matchesKnownBoundaryValue() {
        let ratio = NCContrast.ratio(NCRGB(packed: 0x7676_76), .white)
        #expect(abs(ratio - 4.54) < 0.01)
    }

    @Test("ranks luminance in the expected order")
    func luminanceOrdering() {
        #expect(NCContrast.relativeLuminance(of: .black) == 0)
        #expect(abs(NCContrast.relativeLuminance(of: .white) - 1) < 0.000_001)
        // Green dominates the weighting; blue contributes least.
        let green = NCContrast.relativeLuminance(of: NCRGB(packed: 0x00FF_00))
        let blue = NCContrast.relativeLuminance(of: NCRGB(packed: 0x0000_FF))
        #expect(green > blue)
    }

    @Test("reports AA compliance")
    func thresholds() {
        #expect(NCContrast.meets(NCContrast.aaNormalText, .black, .white))
        #expect(!NCContrast.meets(NCContrast.aaNormalText, NCRGB(packed: 0xCCCC_CC), .white))
    }

    /// The derived foreground must agree with what the Nextcloud server's own PHP
    /// arrives at, or a branded instance renders unreadable primary buttons.
    @Test(
        "derives the same foreground the server picks",
        arguments: [
            (0x0067_9E as UInt32, "#ffffff"),  // stock brand, light appearance
            (0x0091_F2 as UInt32, "#000000"),  // stock brand, dark appearance
        ]
    )
    func preferredForegroundMatchesServer(_ brand: UInt32, _ expected: String) {
        #expect(NCContrast.preferredForeground(on: NCRGB(packed: brand)).hexString == expected)
    }
}
