// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// Supplies a theme to a preview.
///
/// Registered as a trait so that a preview reads as one line rather than four:
///
/// ```swift
/// #Preview("Avatar / fallback chain", traits: .ncTheme) {
///     NCAvatar(displayName: "Lorelai Taylor")
/// }
/// ```
public struct NCThemePreviewModifier: PreviewModifier {
    private let theme: NCTheme

    public init(theme: NCTheme = .nextcloud) {
        self.theme = theme
    }

    public func body(content: Content, context: Void) -> some View {
        content.ncTheme(theme)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    /// The stock Nextcloud theme.
    public static var ncTheme: PreviewTrait<T> {
        modifier(NCThemePreviewModifier())
    }

    /// A theme branded for one instance, for checking that a component reads its
    /// tokens rather than hard-coding Nextcloud blue.
    public static func ncTheme(brand: NCBrand) -> PreviewTrait<T> {
        modifier(NCThemePreviewModifier(theme: NCTheme(brand: brand)))
    }

    /// The trait every "increased contrast" preview uses.
    ///
    /// `\.colorSchemeContrast` is get-only, so no preview can switch macOS's
    /// Increase Contrast on. Half of what that setting does belongs to the
    /// system -- heavier separators, stronger control borders, opaque materials
    /// -- and the only way to see that half is to turn the setting on, in the
    /// canvas accessibility controls or in System Settings.
    ///
    /// The other half is ours, and this drives it. The brand is pinned to a
    /// near-black blue and a near-white one, which is roughly where an instance
    /// that has chosen its colours for contrast lands. A component that
    /// hard-codes Nextcloud blue, or that assumes white reads on the brand,
    /// fails visibly here instead of in a screenshot review.
    ///
    /// One named trait rather than a brand spelled out per preview: three waves
    /// each invented their own `NCBrand(primaryHex:) ?? .nextcloud`, and a
    /// failable initialiser inside a preview falls back to the stock theme in
    /// silence when the literal is wrong, which is the one failure mode a
    /// contrast preview must not have.
    public static var ncIncreasedContrast: PreviewTrait<T> {
        modifier(NCThemePreviewModifier(theme: NCTheme(brand: .previewHighContrast)))
    }
}

extension NCBrand {
    /// The branding behind ``PreviewTrait/ncIncreasedContrast``.
    ///
    /// Built from components rather than from a hex string so that it cannot
    /// fail, and so that a preview never quietly renders the stock theme while
    /// claiming to show a high-contrast one.
    fileprivate static let previewHighContrast = NCBrand(
        lightPrimary: NCRGB(red8: 0, green8: 38, blue8: 63),
        darkPrimary: NCRGB(red8: 199, green8: 229, blue8: 255)
    )
}
