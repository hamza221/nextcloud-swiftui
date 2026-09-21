// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import NextcloudPlatform
public import SwiftUI

/// Nextcloud's button roles.
///
/// Each role is a *system* button style with a token tint. This style draws no
/// shape, no fill, no press animation and no focus ring of its own: the system
/// does the glass, the token supplies the hue.
///
/// ```swift
/// Button(action: send) { Text(LocalizedStringResource(nc: "Send")) }
///     .buttonStyle(.primary)
/// ```
///
/// ## Why this is nearly empty
///
/// A hand-painted rounded rectangle with the brand colour in it looks right in a
/// screenshot and wrong in a toolbar. It misses the press response, the disabled
/// appearance, the keyboard focus ring and the key-window dimming, and it keeps
/// its solid fill when Reduce Transparency is on, where every control beside it
/// changes. All of that arrives free from `.borderedProminent` and `.bordered`,
/// and none of it is worth reimplementing to own a corner radius.
///
/// What is left is the tint, which is the one thing macOS cannot know: the
/// colour the server reported for this instance.
///
/// ## The tint is not always the brand
///
/// ``NCAccentPolicy/instance`` already installs the brand as `.tint` app-wide,
/// so under that policy a primary button is brand-tinted with no style at all.
/// The style earns its place under the other two policies.
/// ``NCAccentPolicy/brandSurfacesOnly`` keeps the user's macOS accent on
/// ordinary controls, and a primary action is a brand surface, so it is tinted
/// here. ``NCAccentPolicy/system`` tints nothing, and the style passes a `nil`
/// tint so the user's accent survives.
///
/// ``NCButtonStyle/Role/error`` ignores the policy. An error colour is a status
/// token rather than branding, and a destructive action is red on every
/// instance.
///
/// ## `Role` and `ButtonRole` are different things
///
/// `.error` colours a button. `Button(role: .destructive)` tells the system what
/// the button *means*, which decides where it lands in a menu and how an alert
/// emphasises it. They are orthogonal, both are worth setting on a delete
/// button, and this style forwards the `ButtonRole` it is given:
///
/// ```swift
/// Button(role: .destructive, action: delete) { Text(LocalizedStringResource(nc: "Delete")) }
///     .buttonStyle(.error)
/// ```
public struct NCButtonStyle: PrimitiveButtonStyle {

    /// What a button means, in Nextcloud's vocabulary.
    public enum Role: Hashable, Sendable, CaseIterable {
        /// The one action a screen is about. Filled, brand-tinted.
        case primary
        /// A secondary action beside a primary one. Bordered.
        case secondary
        /// A low-emphasis action: "Cancel", a link, a row affordance.
        case tertiary
        /// Destructive or failing. Filled, tinted with the error token.
        case error
        /// A glyph with no visible text, in a toolbar or beside a field.
        case icon
    }

    private let role: Role

    /// Creates a style for one role.
    ///
    /// Prefer the shorthands: `.buttonStyle(.primary)`.
    public init(role: Role) {
        self.role = role
    }

    public func makeBody(configuration: Configuration) -> some View {
        Rendered(role: role, configuration: configuration)
    }

    /// The tint comes from the environment, and a `PrimitiveButtonStyle` is not
    /// a `View`, so an `@Environment` property on the style itself never
    /// updates. A nested view is the supported way to read the theme here.
    private struct Rendered: View {
        let role: Role
        let configuration: Configuration

        @Environment(\.ncTheme) private var theme

        var body: some View {
            switch role {
            case .primary:
                Button(configuration)
                    .buttonStyle(.borderedProminent)
                    .tint(brand)
            case .secondary:
                Button(configuration)
                    .buttonStyle(.bordered)
                    .tint(brand)
            case .tertiary:
                // `.foregroundStyle(.tint)` rather than the token directly, so
                // that a `nil` brand falls through to the user's accent instead
                // of needing a second branch.
                Button(configuration)
                    .buttonStyle(.plain)
                    .tint(brand)
                    .foregroundStyle(.tint)
            case .error:
                Button(configuration)
                    .buttonStyle(.borderedProminent)
                    .tint(theme.colors.error.element)
            case .icon:
                Button(configuration)
                    .buttonStyle(.bordered)
                    // A `Label` passed to an icon button keeps its title as the
                    // spoken name, which is how a toolbar stays usable on
                    // VoiceOver. See ``NCLabelStyle``.
                    .labelStyle(.iconOnly)
                    .tint(brand)
                    .frame(
                        minWidth: NCPlatformMetrics.minimumHitTarget,
                        minHeight: NCPlatformMetrics.minimumHitTarget
                    )
            }
        }

        /// `nil` under ``NCAccentPolicy/system``, which leaves the button with
        /// the user's chosen macOS accent.
        private var brand: NCDynamicColor? {
            theme.accentPolicy == .system ? nil : theme.colors.primary
        }
    }
}

extension PrimitiveButtonStyle where Self == NCButtonStyle {
    /// The one action a screen is about. `.borderedProminent` with the brand tint.
    public static var primary: NCButtonStyle { NCButtonStyle(role: .primary) }

    /// A secondary action beside a primary one. `.bordered` with the brand tint.
    public static var secondary: NCButtonStyle { NCButtonStyle(role: .secondary) }

    /// A low-emphasis action. `.plain` with the brand as its foreground.
    public static var tertiary: NCButtonStyle { NCButtonStyle(role: .tertiary) }

    /// Destructive or failing. `.borderedProminent` with the error token.
    public static var error: NCButtonStyle { NCButtonStyle(role: .error) }

    /// A glyph with no visible text, at a full hit target.
    public static var icon: NCButtonStyle { NCButtonStyle(role: .icon) }
}

// ponytail: five roles and no size, width or alignment parameters. Upstream's
// `NcButton` carries `size`, `wide`, `alignment` and `pressed`; on macOS those
// are `.controlSize`, `.frame(maxWidth:)`, the surrounding stack and a `Toggle`,
// all of which already exist. Add a parameter here only when a screen proves the
// system modifier cannot express it.
