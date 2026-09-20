// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

extension EnvironmentValues {
    /// The active design tokens.
    ///
    /// Defaults to ``NCTheme/nextcloud`` so that a view works in a preview, a
    /// test, or an app that has not installed a theme yet.
    @Entry public var ncTheme: NCTheme = .nextcloud
}

extension View {
    /// Installs a theme for this view and everything below it.
    ///
    /// Apply it once, near the root of a `Scene`. Re-applying it deeper is
    /// legitimate but rare -- it is how a preview or a showcase renders one
    /// component under a different instance's branding.
    ///
    /// Under ``NCAccentPolicy/instance`` this also sets `.tint`, so the brand
    /// colour reaches list selection, focus rings and the default button
    /// alongside the avatars and chips that read the token directly.
    public func ncTheme(_ theme: NCTheme) -> some View {
        modifier(NCThemeModifier(theme: theme))
    }
}

/// Installs the theme and, depending on the accent policy, the tint.
private struct NCThemeModifier: ViewModifier {
    let theme: NCTheme

    func body(content: Content) -> some View {
        content
            .environment(\.ncTheme, theme)
            .applyingAccent(theme)
    }
}

extension View {
    @ViewBuilder
    fileprivate func applyingAccent(_ theme: NCTheme) -> some View {
        switch theme.accentPolicy {
        case .instance:
            tint(theme.colors.primary)
        case .brandSurfacesOnly, .system:
            self
        }
    }
}
