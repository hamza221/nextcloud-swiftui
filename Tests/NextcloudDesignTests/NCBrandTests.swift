// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import Testing

@testable import NextcloudDesign

@Suite("Runtime branding")
struct NCBrandTests {

    @Test("accepts the #RRGGBB form a Nextcloud server reports")
    func parsesServerForm() throws {
        let brand = try #require(NCBrand(primaryHex: "#00679e"))
        #expect(brand.lightPrimary.hexString == "#00679e")
        // With no dark value reported, the single colour is used for both.
        #expect(brand.darkPrimary.hexString == "#00679e")
    }

    @Test("fails rather than traps on a malformed brand colour", arguments: ["", "blue", "#12345"])
    func rejectsMalformed(_ input: String) {
        #expect(NCBrand(primaryHex: input) == nil)
    }

    @Test("rejects a malformed dark or foreground override")
    func rejectsMalformedOverrides() {
        #expect(NCBrand(primaryHex: "#00679e", darkPrimaryHex: "nope") == nil)
        #expect(NCBrand(primaryHex: "#00679e", onPrimaryHex: "nope") == nil)
    }

    @Test("derives a readable foreground per appearance")
    func derivesForeground() {
        let stock = NCBrand.nextcloud
        #expect(stock.resolvedOnPrimary.color(for: .light) == NCRGB.white.color)
        #expect(stock.resolvedOnPrimary.color(for: .dark) == NCRGB.black.color)
    }

    @Test("prefers an explicit foreground over a derived one")
    func explicitForegroundWins() throws {
        let brand = try #require(NCBrand(primaryHex: "#00679e", onPrimaryHex: "#ff0000"))
        #expect(brand.resolvedOnPrimary.color(for: .light) == NCRGB(packed: 0xFF00_00).color)
    }

    @Test("derives a readable foreground for arbitrary brand colours")
    func derivedForegroundIsReadable() {
        for packed: UInt32 in [0x0000_00, 0xFFFF_FF, 0xFF00_00, 0x00FF_00, 0x7F7F_7F, 0x123456, 0xFFEE_00] {
            let brand = NCRGB(packed: packed)
            let foreground = NCContrast.preferredForeground(on: brand)
            #expect(
                NCContrast.meets(NCContrast.aaLargeText, brand, foreground),
                "\(brand.hexString) got an unreadable foreground"
            )
        }
    }

    @Test("leaves the transcribed palette alone for the stock brand")
    func stockBrandDoesNotRederive() {
        let theme = NCTheme(brand: .nextcloud)
        // The base theme already carries exact transcribed values; re-deriving
        // them would be strictly worse than leaving them.
        #expect(theme.colors.primaryHover == NCTheme.nextcloud.colors.primaryHover)
        #expect(theme.colors.primarySurface == NCTheme.nextcloud.colors.primarySurface)
        #expect(theme.colors.onPrimarySurface == NCTheme.nextcloud.colors.onPrimarySurface)
    }

    @Test("recolours only the primary family")
    func brandingIsScoped() throws {
        let brand = try #require(NCBrand(primaryHex: "#aa0055"))
        let theme = NCTheme(brand: brand)

        #expect(theme.colors.primary.color(for: .light) == NCRGB(packed: 0xAA00_55).color)
        // Status, favourite and highlight are Nextcloud-wide semantics, not
        // instance branding, so they must survive a rebrand untouched.
        #expect(theme.colors.error == NCTheme.nextcloud.colors.error)
        #expect(theme.colors.warning == NCTheme.nextcloud.colors.warning)
        #expect(theme.colors.success == NCTheme.nextcloud.colors.success)
        #expect(theme.colors.info == NCTheme.nextcloud.colors.info)
        #expect(theme.colors.favorite == NCTheme.nextcloud.colors.favorite)
        #expect(theme.colors.highlight == NCTheme.nextcloud.colors.highlight)
        #expect(theme.colors.userStatus == NCTheme.nextcloud.colors.userStatus)
    }

    /// The derivation formulas are calibrated against the stock light palette.
    /// This pins that calibration so a future tweak cannot quietly drift.
    @Test("derivation reproduces the stock light palette within one unit per channel")
    func derivationIsCalibrated() {
        let base = NCRGB(packed: 0x0067_9E)
        #expect(base.mixed(with: .black, amount: 0.22).hexString == "#00507b")  // actual #00507a
        #expect(base.mixed(with: .white, amount: 0.90).hexString == "#e6f0f5")  // actual #e5eff5
        #expect(base.mixed(with: .black, amount: 0.60).hexString == "#00293f")  // actual #00293f
    }
}
