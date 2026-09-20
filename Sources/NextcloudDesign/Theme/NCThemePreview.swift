// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
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
}
