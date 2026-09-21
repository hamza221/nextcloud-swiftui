// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// A colour token that carries its own appearance variants.
///
/// The `ShapeStyle` conformance is the load-bearing part. It lets a token be
/// passed anywhere SwiftUI takes a style:
///
/// ```swift
/// Text(name).foregroundStyle(theme.colors.favorite)
/// Circle().fill(theme.colors.primary)
/// banner.background(theme.colors.error.surface, in: .rect(cornerRadius: r))
/// ```
///
/// which in turn means no component ever reads `\.colorScheme` to pick between a
/// light and a dark value. One protocol conformance replaces the whole of
/// `NcThemeProvider` and `useIsDarkTheme` from the Vue library.
public nonisolated struct NCDynamicColor: ShapeStyle, Hashable, Sendable {
    /// The value used in a light appearance at standard contrast.
    public var light: Color
    /// The value used in a dark appearance at standard contrast.
    public var dark: Color
    /// The value used in a light appearance when Increase Contrast is on.
    public var lightIncreasedContrast: Color
    /// The value used in a dark appearance when Increase Contrast is on.
    public var darkIncreasedContrast: Color

    /// Creates a token with an explicit value for all four appearances.
    public init(
        light: Color,
        dark: Color,
        lightIncreasedContrast: Color,
        darkIncreasedContrast: Color
    ) {
        self.light = light
        self.dark = dark
        self.lightIncreasedContrast = lightIncreasedContrast
        self.darkIncreasedContrast = darkIncreasedContrast
    }

    /// Creates a token whose increased-contrast variants match its standard ones.
    ///
    /// Most Nextcloud tokens land here: the web system has no high-contrast
    /// theme to transcribe, so a deliberate equal value is more honest than a
    /// guessed one.
    public init(light: Color, dark: Color) {
        self.init(
            light: light,
            dark: dark,
            lightIncreasedContrast: light,
            darkIncreasedContrast: dark
        )
    }

    /// Creates a token with the same value in every appearance.
    public init(_ uniform: Color) {
        self.init(light: uniform, dark: uniform)
    }

    /// Creates a token from `NCRGB` values.
    public init(light: NCRGB, dark: NCRGB) {
        self.init(light: light.color, dark: dark.color)
    }

    /// The value for a given appearance.
    public func color(
        for scheme: ColorScheme,
        contrast: ColorSchemeContrast = .standard
    ) -> Color {
        switch (scheme, contrast) {
        case (.dark, .increased): darkIncreasedContrast
        case (.dark, _): dark
        case (_, .increased): lightIncreasedContrast
        case (_, _): light
        }
    }

    /// Returns the same token with every variant scaled to the given opacity.
    public func opacity(_ opacity: Double) -> NCDynamicColor {
        NCDynamicColor(
            light: light.opacity(opacity),
            dark: dark.opacity(opacity),
            lightIncreasedContrast: lightIncreasedContrast.opacity(opacity),
            darkIncreasedContrast: darkIncreasedContrast.opacity(opacity)
        )
    }

    // MARK: ShapeStyle

    public func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        color(for: environment.colorScheme, contrast: environment.colorSchemeContrast)
            .resolve(in: environment)
    }
}

extension NCDynamicColor {
    /// Token-transcription convenience taking packed `0xRRGGBB` literals, which
    /// keeps ``NCColorTokens`` readable against the CSS it is transcribed from.
    internal init(
        light: UInt32,
        dark: UInt32,
        lightIncreasedContrast: UInt32? = nil,
        darkIncreasedContrast: UInt32? = nil
    ) {
        self.init(
            light: NCRGB(packed: light).color,
            dark: NCRGB(packed: dark).color,
            lightIncreasedContrast: NCRGB(packed: lightIncreasedContrast ?? light).color,
            darkIncreasedContrast: NCRGB(packed: darkIncreasedContrast ?? dark).color
        )
    }
}
