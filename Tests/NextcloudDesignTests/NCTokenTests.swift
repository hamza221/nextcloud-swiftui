// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import Testing

@testable import NextcloudDesign

@Suite("Tokens and theme")
struct NCTokenTests {

    @Test("selects a value per appearance and contrast")
    func dynamicColourSelection() {
        let token = NCDynamicColor(
            light: NCRGB(packed: 0x111_111).color,
            dark: NCRGB(packed: 0x222_222).color,
            lightIncreasedContrast: NCRGB(packed: 0x333_333).color,
            darkIncreasedContrast: NCRGB(packed: 0x444_444).color
        )
        #expect(token.color(for: .light, contrast: .standard) == token.light)
        #expect(token.color(for: .dark, contrast: .standard) == token.dark)
        #expect(token.color(for: .light, contrast: .increased) == token.lightIncreasedContrast)
        #expect(token.color(for: .dark, contrast: .increased) == token.darkIncreasedContrast)
    }

    @Test("falls back to the standard value when no increased-contrast value exists")
    func increasedContrastFallback() {
        let token = NCDynamicColor(light: Color.white, dark: Color.black)
        #expect(token.color(for: .light, contrast: .increased) == token.light)
        #expect(token.color(for: .dark, contrast: .increased) == token.dark)
    }

    @Test("transcribes the stock palette from the styleguide")
    func stockPaletteTranscription() {
        let colours = NCColorTokens.nextcloud
        #expect(colours.primary.light == NCRGB(packed: 0x0067_9E).color)
        #expect(colours.primary.dark == NCRGB(packed: 0x0091_F2).color)
        #expect(colours.favorite.light == NCRGB(packed: 0xA372_00).color)
        #expect(colours.favorite.dark == NCRGB(packed: 0xFFDE_00).color)
        #expect(colours.error.element.light == NCRGB(packed: 0xC900_00).color)
        #expect(colours.success.surface.light == NCRGB(packed: 0xD8F3_DA).color)
        #expect(colours.info.onSurface.dark == NCRGB(packed: 0x00AE_FF).color)
    }

    /// Upstream sets these as literals specifically "to not rely on server
    /// variables", so they must not pick up an instance's branding.
    @Test("keeps presence colours independent of branding")
    func userStatusColours() {
        let status = NCUserStatusColors.nextcloud
        #expect(status.online.light == NCRGB(packed: 0x2D7B_41).color)
        #expect(status.away.light == NCRGB(packed: 0xC888_00).color)
        #expect(status.busy.light == NCRGB(packed: 0xDB06_06).color)
        // Online, away and busy are identical across appearances; only the
        // offline grey moves, matching upstream's invert-if-dark filter.
        #expect(status.online.light == status.online.dark)
        #expect(status.offline.light != status.offline.dark)
    }

    @Test("defaults to the instance accent policy")
    func accentPolicyDefault() {
        #expect(NCTheme.nextcloud.accentPolicy == .instance)
    }

    @Test("is cheap to diff")
    func themeIsHashable() {
        #expect(NCTheme.nextcloud == NCTheme.nextcloud)
        var recoloured = NCTheme.nextcloud
        recoloured.colors.favorite = NCDynamicColor(.red)
        #expect(recoloured != NCTheme.nextcloud)
    }
}

@Suite("Gradient tokens")
struct NCDynamicGradientTests {

    /// The assistant border gradient ends at 125%, so its final colour is never
    /// reached inside the box. Clamping the stop to 1.0 would reach `#6104a4`
    /// early and visibly change the ramp; trimming interpolates instead.
    @Test("trims an over-range stop by interpolation, not by clamping")
    func trimsOverRangeStops() {
        let stops = NCDynamicGradient.trimmedToUnitRange([
            NCGradientStop(0x7398_FE, 50),
            NCGradientStop(0x6104_A4, 125),
        ])
        #expect(stops.first?.location == 0)
        #expect(stops.last?.location == 1)
        #expect(stops.last?.color.hexString == "#6735c2")
        #expect(stops.last?.color.hexString != "#6104a4")
    }

    @Test("holds the end colours flat outside the authored range")
    func holdsEndsFlat() {
        let stops = NCDynamicGradient.trimmedToUnitRange([
            NCGradientStop(0xA569_D3, 12),
            NCGradientStop(0x4220_83, 86),
        ])
        #expect(stops.first?.color.hexString == "#a569d3")
        #expect(stops.last?.color.hexString == "#422083")
    }

    @Test("converts CSS angles to SwiftUI unit points")
    func angleConversion() {
        // CSS measures from "to top", clockwise; SwiftUI's y axis grows downward.
        let up = NCDynamicGradient.unitPoints(for: .degrees(0))
        #expect(up.start.y == 1 && up.end.y == 0)

        let right = NCDynamicGradient.unitPoints(for: .degrees(90))
        #expect(right.start.x == 0 && right.end.x == 1)

        let down = NCDynamicGradient.unitPoints(for: .degrees(180))
        #expect(abs(down.start.y - 0) < 0.000_001 && abs(down.end.y - 1) < 0.000_001)
    }

    @Test("rotates assistant gradients for dark mode, as the CSS does")
    func perAppearanceAngles() {
        let element = NCAssistantColors.nextcloud.element
        #expect(element.lightAngle == .degrees(214))
        #expect(element.darkAngle == .degrees(238))
        #expect(NCAssistantColors.nextcloud.icon.darkAngle == .degrees(285))
    }
}
