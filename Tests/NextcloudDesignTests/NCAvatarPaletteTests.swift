// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import Testing

@testable import NextcloudDesign

@Suite("Avatar palette")
struct NCAvatarPaletteTests {

    @Test("generates the 18-entry ring usernameToColor indexes into")
    func standardPalette() {
        #expect(
            NCAvatarPalette.standard.map(\.hexString) == [
                "#b6469d", "#bc5c91", "#c37285", "#c98879", "#d09e6d", "#d6b461",
                "#ddcb55", "#b8be68", "#93b27b", "#6ea68f", "#499aa2", "#248eb5",
                "#0082c9", "#1e78c1", "#3c6eba", "#5b64b3", "#795aab", "#9750a4",
            ]
        )
    }

    /// Upstream keeps a *hand-written* twelve-colour array so it can attach
    /// translated colour names, commented "Like GenColor(4) but with labels".
    /// Pinning against it checks the blend maths against a source that was not
    /// produced by the blend maths.
    @Test("reproduces the hand-written upstream defaultPalette at four steps")
    func matchesUpstreamNamedPalette() {
        #expect(
            NCAvatarPalette.generate(steps: 4).map(\.hexString) == [
                "#b6469d", "#bf678b", "#c98879", "#d3a967",
                "#ddcb55", "#a5b872", "#6ea68f", "#3794ac",
                "#0082c9", "#2d73be", "#5b64b3", "#8855a8",
            ]
        )
    }

    @Test("starts each leg on its base colour")
    func legsStartOnBaseColours() {
        let palette = NCAvatarPalette.generate(steps: 6)
        #expect(palette[0] == NCAvatarPalette.basePurple)
        #expect(palette[6] == NCAvatarPalette.baseGold)
        #expect(palette[12] == NCAvatarPalette.baseBlue)
    }

    @Test("produces three legs of `steps` entries", arguments: [1, 2, 3, 4, 6, 8, 12])
    func lengthIsThreeTimesSteps(_ steps: Int) {
        #expect(NCAvatarPalette.generate(steps: steps).count == steps * 3)
    }

    @Test("coerces a non-positive step count to six, as upstream does")
    func nonPositiveStepsFallBack() {
        #expect(NCAvatarPalette.generate(steps: 0) == NCAvatarPalette.standard)
        #expect(NCAvatarPalette.generate(steps: -5) == NCAvatarPalette.standard)
    }

    /// The blend truncates each channel. Rounding to nearest instead would move
    /// several entries by one unit and silently break avatar parity, so the
    /// direction is asserted on a case where the two disagree.
    @Test("truncates rather than rounds")
    func truncatesChannels() {
        // Purple -> gold, step 1 of 6: red is 182 + 39/6 = 188.5.
        #expect(NCAvatarPalette.standard[1].components8.red == 188)
    }
}
