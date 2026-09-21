// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

/// Every design token, in one value.
///
/// One struct rather than forty environment keys. That buys a single environment
/// read per view, one assignment to re-theme an entire running app the moment a
/// capabilities call returns, `Hashable` for cheap environment diffing, and a
/// value that is trivial to construct in a test or a preview.
///
/// Install it near the root of a `Scene`:
///
/// ```swift
/// WindowGroup {
///     ContentView().ncTheme(theme)
/// }
/// ```
public nonisolated struct NCTheme: Hashable, Sendable {
    public var colors: NCColorTokens
    public var metrics: NCMetrics
    public var motion: NCMotion
    public var typography: NCTypography
    /// Whether the instance's brand colour overrides the user's system accent.
    public var accentPolicy: NCAccentPolicy

    public init(
        colors: NCColorTokens = .nextcloud,
        metrics: NCMetrics = .macOS,
        motion: NCMotion = .nextcloud,
        typography: NCTypography = .nextcloud,
        accentPolicy: NCAccentPolicy = .instance
    ) {
        self.colors = colors
        self.metrics = metrics
        self.motion = motion
        self.typography = typography
        self.accentPolicy = accentPolicy
    }

    /// The stock Nextcloud theme.
    public static let nextcloud = NCTheme()

    /// A theme recoloured for one instance's branding.
    ///
    /// Only the primary family changes; status roles, favourite, highlight and
    /// the avatar palette are Nextcloud-wide semantics and are not branded.
    ///
    /// The supporting members of the primary family -- hover, surface and the
    /// text on that surface -- are *derived*, because a server reports a brand
    /// colour but not the shades it computes from it in PHP. The derivation
    /// reproduces the stock light palette to within one unit per channel; in
    /// dark appearances it is a visually reasonable approximation rather than an
    /// exact match. A consumer that has the server's exact values should build
    /// ``NCColorTokens`` directly instead.
    public init(brand: NCBrand, base: NCTheme = .nextcloud) {
        var colors = base.colors

        // The stock brand needs no derivation: `base` already carries the
        // transcribed values, which are exact.
        if brand != .nextcloud {
            colors.primary = brand.primary
            colors.primaryHover = NCDynamicColor(
                light: brand.lightPrimary.mixed(with: .black, amount: 0.22),
                dark: brand.darkPrimary.mixed(with: .white, amount: 0.15)
            )
            colors.primarySurface = NCDynamicColor(
                light: brand.lightPrimary.mixed(with: .white, amount: 0.90),
                dark: brand.darkPrimary.mixed(with: .black, amount: 0.86)
            )
            colors.onPrimarySurface = NCDynamicColor(
                light: brand.lightPrimary.mixed(with: .black, amount: 0.60),
                dark: brand.darkPrimary.mixed(with: .white, amount: 0.55)
            )
        }
        colors.onPrimary = brand.resolvedOnPrimary

        self.init(
            colors: colors,
            metrics: base.metrics,
            motion: base.motion,
            typography: base.typography,
            accentPolicy: base.accentPolicy
        )
    }
}

/// Whether an instance's brand colour replaces the user's chosen macOS accent.
///
/// The default is ``instance``, which is a deliberate branding decision rather
/// than an oversight: a Nextcloud client is expected to look like the instance
/// it is connected to. Shipping the other cases means an app can disagree
/// without needing a change to this library.
public nonisolated enum NCAccentPolicy: Hashable, Sendable, CaseIterable {
    /// The brand colour tints everything, including list selection and focus
    /// rings. Overrides the user's system accent.
    case instance
    /// The brand colour appears only on Nextcloud-specific surfaces -- avatars,
    /// chips, status -- while controls keep the user's system accent.
    case brandSurfacesOnly
    /// The brand colour is not used as a tint at all.
    case system
}
