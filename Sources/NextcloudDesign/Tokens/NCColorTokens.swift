// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

/// The colour half of a ``NCTheme``.
///
/// ## What is deliberately absent
///
/// `@nextcloud/vue` reads about 180 CSS custom properties that the server
/// injects at runtime. Most of them have a macOS semantic equivalent, and every
/// token that duplicates a system semantic will look wrong the first time Apple
/// changes the system appearance -- a live risk on a platform where Liquid Glass
/// has only just landed. So these are not tokens here:
///
/// | Web token | Use instead |
/// | --- | --- |
/// | `--color-main-background`, `--color-background-*` | `.windowBackground`, `.regularMaterial`, `glassEffect()` |
/// | `--color-main-text`, `--color-text-maxcontrast` | `.primary`, `.secondary`, `.tertiary` |
/// | `--color-border*` | `.separator`, the `.fill` hierarchy |
/// | `--color-placeholder-*` | `.redacted(reason: .placeholder)` |
/// | `--font-face`, `--default-font-size`, `--default-line-height` | Dynamic Type |
/// | `--color-scrollbar`, `--color-box-shadow*` | system-drawn |
/// | `--color-*-rgb` | deprecated upstream |
///
/// What remains is what macOS has no opinion about: Nextcloud's brand identity
/// and its domain semantics.
public nonisolated struct NCColorTokens: Hashable, Sendable {

    // MARK: Primary family

    /// The instance's brand colour. Tints controls app-wide under the default
    /// ``NCAccentPolicy/instance``.
    public var primary: NCDynamicColor
    /// The brand colour in a hovered or pressed state.
    public var primaryHover: NCDynamicColor
    /// A tinted surface derived from the brand colour, for selected rows and
    /// quiet emphasis. `--color-primary-light`.
    public var primarySurface: NCDynamicColor
    /// Text and icons drawn on ``primarySurface``. `--color-primary-light-text`.
    public var onPrimarySurface: NCDynamicColor
    /// Text and icons drawn directly on ``primary``.
    ///
    /// Derived through ``NCContrast`` when a server reports no explicit value.
    public var onPrimary: NCDynamicColor

    // MARK: Status roles

    /// Destructive and failure states.
    public var error: NCStatusColors
    /// Cautionary states.
    public var warning: NCStatusColors
    /// Confirmation states.
    public var success: NCStatusColors
    /// Neutral informational states.
    public var info: NCStatusColors

    // MARK: Domain accents

    /// The star colour for favourited items. `--color-favorite`.
    public var favorite: NCDynamicColor
    /// The background behind a search hit. `--color-mark`.
    public var highlight: NCDynamicColor
    /// Presence colours for `NCUserStatusBadge`.
    public var userStatus: NCUserStatusColors
    /// Gradients reserved for AI-generated content.
    public var assistant: NCAssistantColors

    public init(
        primary: NCDynamicColor,
        primaryHover: NCDynamicColor,
        primarySurface: NCDynamicColor,
        onPrimarySurface: NCDynamicColor,
        onPrimary: NCDynamicColor,
        error: NCStatusColors,
        warning: NCStatusColors,
        success: NCStatusColors,
        info: NCStatusColors,
        favorite: NCDynamicColor,
        highlight: NCDynamicColor,
        userStatus: NCUserStatusColors,
        assistant: NCAssistantColors
    ) {
        self.primary = primary
        self.primaryHover = primaryHover
        self.primarySurface = primarySurface
        self.onPrimarySurface = onPrimarySurface
        self.onPrimary = onPrimary
        self.error = error
        self.warning = warning
        self.success = success
        self.info = info
        self.favorite = favorite
        self.highlight = highlight
        self.userStatus = userStatus
        self.assistant = assistant
    }

    /// The stock Nextcloud palette, transcribed from `styleguide/assets/default.css`
    /// and `dark.css` in `@nextcloud/vue`.
    public static let nextcloud = NCColorTokens(
        primary: NCDynamicColor(light: 0x0067_9E, dark: 0x0091_F2),
        primaryHover: NCDynamicColor(light: 0x0050_7A, dark: 0x17A2_FF),
        primarySurface: NCDynamicColor(light: 0xE5EF_F5, dark: 0x1423_2C),
        onPrimarySurface: NCDynamicColor(light: 0x0029_3F, dark: 0x99C2_D8),
        onPrimary: NCDynamicColor(light: 0xFFFF_FF, dark: 0x0000_00),
        error: NCStatusColors(
            element: NCDynamicColor(light: 0xC900_00, dark: 0xFF50_50),
            surface: NCDynamicColor(light: 0xFFE7_E7, dark: 0x5521_21),
            onSurface: NCDynamicColor(light: 0x8A00_00, dark: 0xFFCC_CC)
        ),
        warning: NCStatusColors(
            element: NCDynamicColor(light: 0xBF79_00, dark: 0xFFCC_00),
            surface: NCDynamicColor(light: 0xFFEE_C5, dark: 0x3D30_10),
            onSurface: NCDynamicColor(light: 0x6647_00, dark: 0xFFEE_C5)
        ),
        success: NCStatusColors(
            element: NCDynamicColor(light: 0x099F_05, dark: 0x40A3_30),
            surface: NCDynamicColor(light: 0xD8F3_DA, dark: 0x1132_1A),
            onSurface: NCDynamicColor(light: 0x0054_16, dark: 0xD5F2_DC)
        ),
        info: NCStatusColors(
            element: NCDynamicColor(light: 0x0077_C7, dark: 0x0099_E0),
            surface: NCDynamicColor(light: 0xD5F1_FA, dark: 0x0035_53),
            onSurface: NCDynamicColor(light: 0x0066_AC, dark: 0x00AE_FF)
        ),
        favorite: NCDynamicColor(light: 0xA372_00, dark: 0xFFDE_00),
        // `dark.css` defines no `--color-mark`; the dark value reuses the warning
        // surface, which is the closest transcribed equivalent.
        highlight: NCDynamicColor(light: 0xFFF0_C7, dark: 0x3D30_10),
        userStatus: .nextcloud,
        assistant: .nextcloud
    )
}

/// The three slots a status role occupies.
///
/// Collapsed from the web's four-plus-hover set. `--color-*-hover` is dropped
/// because macOS derives a pressed state from the base colour itself, and
/// `--color-text-*` is dropped because ``element`` is within a rounding error of
/// it (`#c90000` against `#bf0000` for error) and serves the same purpose.
public nonisolated struct NCStatusColors: Hashable, Sendable {
    /// The solid fill: icon tints, indicator dots, filled buttons.
    public var element: NCDynamicColor
    /// The quiet background of an inline banner.
    public var surface: NCDynamicColor
    /// Text and icons drawn on ``surface``.
    public var onSurface: NCDynamicColor

    public init(element: NCDynamicColor, surface: NCDynamicColor, onSurface: NCDynamicColor) {
        self.element = element
        self.surface = surface
        self.onSurface = onSurface
    }
}

/// Presence colours.
///
/// Upstream sets these as literals with the comment "Custom colors for the svg
/// icons, to not rely on server variables", so unlike the rest of the palette
/// they are deliberately independent of an instance's branding and identical
/// across appearances.
public nonisolated struct NCUserStatusColors: Hashable, Sendable {
    public var online: NCDynamicColor
    public var away: NCDynamicColor
    public var busy: NCDynamicColor
    public var offline: NCDynamicColor

    public init(
        online: NCDynamicColor,
        away: NCDynamicColor,
        busy: NCDynamicColor,
        offline: NCDynamicColor
    ) {
        self.online = online
        self.away = away
        self.busy = busy
        self.offline = offline
    }

    public static let nextcloud = NCUserStatusColors(
        online: NCDynamicColor(NCRGB(packed: 0x2D7B_41).color),
        away: NCDynamicColor(NCRGB(packed: 0xC888_00).color),
        busy: NCDynamicColor(NCRGB(packed: 0xDB06_06).color),
        // Upstream inverts the invisible icon in dark mode via a CSS filter;
        // invert(#6B6B6B) is #949494.
        offline: NCDynamicColor(light: 0x6B6B_6B, dark: 0x9494_94)
    )
}
