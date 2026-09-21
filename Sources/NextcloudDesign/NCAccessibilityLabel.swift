// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// How a view describes itself to assistive technology.
///
/// This is required API, not documentation. `@nextcloud/vue` exposes `ariaLabel`
/// as an optional prop, which means it gets skipped -- an optional accessibility
/// affordance is one that is absent in most call sites. Components here take this
/// type non-optionally instead, so that *unlabelled construction is impossible*
/// and the author has to make a decision, even if that decision is
/// ``decorative``.
public nonisolated enum NCAccessibilityLabel: Sendable {
    /// Hidden from assistive technology.
    ///
    /// Correct when an adjacent view already carries the meaning -- the
    /// chevron in a row that VoiceOver reads as one element, or an icon beside
    /// its own text label. Choosing this deliberately is fine; arriving at it by
    /// omission is what this type prevents.
    case decorative

    /// A translated string from the library or the app.
    case text(LocalizedStringResource)

    /// Runtime data, such as a display name or a file name.
    ///
    /// Separate from ``text(_:)`` because this must never be run through a
    /// localisation table.
    case content(String)
}

extension View {
    /// Applies an ``NCAccessibilityLabel``.
    public func ncAccessibilityLabel(_ label: NCAccessibilityLabel) -> some View {
        modifier(NCAccessibilityLabelModifier(label: label))
    }
}

private struct NCAccessibilityLabelModifier: ViewModifier {
    let label: NCAccessibilityLabel

    func body(content: Content) -> some View {
        switch label {
        case .decorative:
            content.accessibilityHidden(true)
        case .text(let resource):
            content.accessibilityLabel(Text(resource))
        case .content(let string):
            content.accessibilityLabel(Text(verbatim: string))
        }
    }
}
