// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

/// An instance's branding.
///
/// The library accepts branding, it never fetches it. An app reads the server's
/// capabilities response with its own authenticated client and hands the result
/// here.
///
/// ```swift
/// guard let brand = NCBrand(primaryHex: capabilities.theming.color) else { return }
/// ContentView().ncTheme(NCTheme(brand: brand))
/// ```
public nonisolated struct NCBrand: Hashable, Sendable {
    /// The brand colour used in a light appearance.
    public var lightPrimary: NCRGB
    /// The brand colour used in a dark appearance.
    ///
    /// Nextcloud servers brighten the brand colour for dark mode (the stock
    /// instance goes from `#00679e` to `#0091f2`) because the light-mode value is
    /// usually too dark to read against a dark background.
    public var darkPrimary: NCRGB
    /// An explicit foreground for the brand colour.
    ///
    /// `nil` means "derive it", which is the common case: most servers report a
    /// brand colour without a matching text colour.
    public var onPrimary: NCDynamicColor?

    /// Creates branding from `NCRGB` values.
    ///
    /// - Parameters:
    ///   - lightPrimary: The brand colour for a light appearance.
    ///   - darkPrimary: The brand colour for a dark appearance. Defaults to
    ///     `lightPrimary`.
    ///   - onPrimary: An explicit foreground, or `nil` to derive one.
    public init(
        lightPrimary: NCRGB,
        darkPrimary: NCRGB? = nil,
        onPrimary: NCDynamicColor? = nil
    ) {
        self.lightPrimary = lightPrimary
        self.darkPrimary = darkPrimary ?? lightPrimary
        self.onPrimary = onPrimary
    }

    /// Creates branding from the `#RRGGBB` strings a Nextcloud server reports.
    ///
    /// Returns `nil` on malformed input rather than trapping: this value comes
    /// off the network, and a misconfigured instance must not crash the client.
    ///
    /// - Parameters:
    ///   - primaryHex: The brand colour, as `#RRGGBB`.
    ///   - darkPrimaryHex: The dark-appearance brand colour. Defaults to
    ///     `primaryHex`.
    ///   - onPrimaryHex: An explicit foreground. Defaults to a derived one.
    public init?(
        primaryHex: String,
        darkPrimaryHex: String? = nil,
        onPrimaryHex: String? = nil
    ) {
        guard let light = NCRGB(hex: primaryHex) else { return nil }

        let dark: NCRGB
        if let darkPrimaryHex {
            guard let parsed = NCRGB(hex: darkPrimaryHex) else { return nil }
            dark = parsed
        } else {
            dark = light
        }

        let foreground: NCDynamicColor?
        if let onPrimaryHex {
            guard let parsed = NCRGB(hex: onPrimaryHex) else { return nil }
            foreground = NCDynamicColor(parsed.color)
        } else {
            foreground = nil
        }

        self.init(lightPrimary: light, darkPrimary: dark, onPrimary: foreground)
    }

    /// The brand colour as a token.
    public var primary: NCDynamicColor {
        NCDynamicColor(light: lightPrimary, dark: darkPrimary)
    }

    /// The foreground to use on ``primary``: the supplied one, or the higher
    /// contrast of white and black against each appearance's brand colour.
    ///
    /// Deriving per appearance matters. For the stock instance this picks white
    /// on `#00679e` in light mode and black on `#0091f2` in dark mode, which is
    /// exactly what the server's own PHP arrives at.
    public var resolvedOnPrimary: NCDynamicColor {
        if let onPrimary { return onPrimary }
        return NCDynamicColor(
            light: NCContrast.preferredForeground(on: lightPrimary),
            dark: NCContrast.preferredForeground(on: darkPrimary)
        )
    }

    /// The contrast ratio between the brand colour and its foreground, per
    /// appearance.
    ///
    /// Exposed so an app can warn an administrator that their chosen brand
    /// colour is unreadable, which the web client cannot easily do.
    public func onPrimaryContrastRatio(for scheme: NCColorSchemeVariant) -> Double {
        let background = scheme == .dark ? darkPrimary : lightPrimary
        return NCContrast.ratio(background, NCContrast.preferredForeground(on: background))
    }

    /// The stock Nextcloud branding, used when a server reports none.
    public static let nextcloud = NCBrand(
        lightPrimary: NCRGB(packed: 0x0067_9E),
        darkPrimary: NCRGB(packed: 0x0091_F2)
    )
}

/// A light/dark selector that does not require importing SwiftUI's
/// `ColorScheme` into non-view code.
public nonisolated enum NCColorSchemeVariant: Hashable, Sendable {
    case light
    case dark
}
