// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// The dimensional half of a ``NCTheme``.
///
/// macOS metrics win over the web's. The 4px grid baseline, the 34pt clickable
/// area and the web radii are all deliberately not ported: a 34pt row in a macOS
/// sidebar is visibly too tall, and a control that does not match its neighbours
/// reads as a foreign widget however correct its colour is.
///
/// What survives is the *shape* of the web scale -- four radii, a control scale,
/// an avatar scale -- with values chosen for macOS.
public nonisolated struct NCMetrics: Hashable, Sendable {
    public var radius: NCRadiusScale
    public var spacing: NCSpacingScale
    public var icon: NCIconScale
    public var avatar: NCAvatarScale

    public init(
        radius: NCRadiusScale = .macOS,
        spacing: NCSpacingScale = .macOS,
        icon: NCIconScale = .macOS,
        avatar: NCAvatarScale = .macOS
    ) {
        self.radius = radius
        self.spacing = spacing
        self.icon = icon
        self.avatar = avatar
    }

    public static let macOS = NCMetrics()
}

/// Corner radii.
///
/// Four slots, matching the web's semantic split, at macOS values rather than
/// the web's 4/8/12/16. A pill shape is not a radius: use `Capsule()`.
public nonisolated struct NCRadiusScale: Hashable, Sendable {
    /// Badges, swatches, small indicators.
    public var small: CGFloat
    /// Buttons, fields, list and navigation rows.
    public var element: CGFloat
    /// Menus and popovers.
    public var container: CGFloat
    /// Sheets, windows, and anything with a Liquid Glass surface.
    public var containerLarge: CGFloat

    public init(small: CGFloat, element: CGFloat, container: CGFloat, containerLarge: CGFloat) {
        self.small = small
        self.element = element
        self.container = container
        self.containerLarge = containerLarge
    }

    public static let macOS = NCRadiusScale(
        small: 4,
        element: 6,
        container: 12,
        containerLarge: 16
    )
}

/// Spacing.
///
/// A scale rather than a grid: the point of dropping the 4px baseline is that
/// macOS spacing is not uniformly quantised. These exist so that no component
/// writes a numeric literal into `.padding`, which SwiftLint enforces.
public nonisolated struct NCSpacingScale: Hashable, Sendable {
    /// Between an icon and its immediately adjacent label.
    public var hairline: CGFloat
    /// Within a compact control.
    public var tight: CGFloat
    /// The default gap between related elements.
    public var standard: CGFloat
    /// Between groups within a row.
    public var comfortable: CGFloat
    /// Window and sheet margins.
    public var loose: CGFloat

    public init(
        hairline: CGFloat,
        tight: CGFloat,
        standard: CGFloat,
        comfortable: CGFloat,
        loose: CGFloat
    ) {
        self.hairline = hairline
        self.tight = tight
        self.standard = standard
        self.comfortable = comfortable
        self.loose = loose
    }

    public static let macOS = NCSpacingScale(
        hairline: 2,
        tight: 4,
        standard: 8,
        comfortable: 12,
        loose: 20
    )
}

/// Icon sizes.
///
/// Material Design Icons have a 24-unit canvas with a 20-unit live area, so
/// these are chosen to land the glyph on whole pixels at 1x and 2x.
public nonisolated struct NCIconScale: Hashable, Sendable {
    public var small: CGFloat
    public var medium: CGFloat
    public var large: CGFloat

    public init(small: CGFloat, medium: CGFloat, large: CGFloat) {
        self.small = small
        self.medium = medium
        self.large = large
    }

    public static let macOS = NCIconScale(small: 12, medium: 16, large: 20)
}

/// Avatar diameters.
public nonisolated struct NCAvatarScale: Hashable, Sendable {
    /// Inline in a line of text, or on a chip.
    public var small: CGFloat
    /// The default: a list row.
    public var medium: CGFloat
    /// A message header or a card.
    public var large: CGFloat
    /// A profile card.
    public var extraLarge: CGFloat

    public init(small: CGFloat, medium: CGFloat, large: CGFloat, extraLarge: CGFloat) {
        self.small = small
        self.medium = medium
        self.large = large
        self.extraLarge = extraLarge
    }

    public static let macOS = NCAvatarScale(
        small: 20,
        medium: 32,
        large: 44,
        extraLarge: 64
    )
}
