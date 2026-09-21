// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// Nextcloud's determinate bar: an upload, a sync, a background job.
///
/// ```swift
/// ProgressView(value: upload.sent, total: upload.size) {
///     Text(verbatim: upload.filename)
/// } currentValueLabel: {
///     Text(upload.sent, format: .byteCount(style: .file))
/// }
/// .progressViewStyle(.normal)
/// ```
///
/// ## What `.linear` already gives you
///
/// Everything except the colour. The track, the fill, the rounded ends, the
/// title above and the current-value label below, the animation between values,
/// the indeterminate sweep when no value is bound, the Reduce Motion response,
/// and the spoken percentage that VoiceOver reads without being asked. So this
/// style is `.linear` plus a tint, and that is the whole delta.
///
/// Drawing the bar by hand would buy a track height and cost all of the above.
/// The height is not worth it.
///
/// ## The roles
///
/// ``NCProgressStyle/Role/normal`` follows `NCAccentPolicy` the way
/// ``NCButtonStyle`` does: brand-tinted unless the app asked for the user's
/// macOS accent. ``NCProgressStyle/Role/warning`` and
/// ``NCProgressStyle/Role/error`` are status tokens and ignore the policy, so a
/// stalled sync is amber and a failed upload is red on every instance.
///
/// A role is colour only. It says nothing about whether the transfer is still
/// running, so a failed upload still needs its own text beside the bar --
/// colour alone is not a message.
public struct NCProgressStyle: ProgressViewStyle {

    /// What the progress means.
    public enum Role: Hashable, Sendable, CaseIterable {
        /// Running normally.
        case normal
        /// Stalled, retrying, or running out of quota.
        case warning
        /// Failed.
        case error
    }

    private let role: Role

    /// Creates a style for one role.
    ///
    /// Prefer the shorthands: `.progressViewStyle(.normal)`.
    public init(role: Role = .normal) {
        self.role = role
    }

    public func makeBody(configuration: Configuration) -> some View {
        Rendered(role: role, configuration: configuration)
    }

    /// Nested for the same reason as ``NCButtonStyle``: a `ProgressViewStyle` is
    /// not a `View`, so an `@Environment` property on it never updates.
    private struct Rendered: View {
        let role: Role
        let configuration: Configuration

        @Environment(\.ncTheme) private var theme

        var body: some View {
            // Setting the style explicitly overrides the environment, so this
            // resolves to the system style rather than recursing.
            ProgressView(configuration)
                .progressViewStyle(.linear)
                .tint(tint)
        }

        private var tint: NCDynamicColor? {
            switch role {
            case .normal: theme.accentPolicy == .system ? nil : theme.colors.primary
            case .warning: theme.colors.warning.element
            case .error: theme.colors.error.element
            }
        }
    }
}

extension ProgressViewStyle where Self == NCProgressStyle {
    /// A transfer running normally. `.linear` with the brand tint.
    public static var normal: NCProgressStyle { NCProgressStyle(role: .normal) }

    /// A transfer that has stalled or is retrying. `.linear` with the warning token.
    public static var warning: NCProgressStyle { NCProgressStyle(role: .warning) }

    /// A transfer that failed. `.linear` with the error token.
    public static var error: NCProgressStyle { NCProgressStyle(role: .error) }
}

// ponytail: no circular variant and no track-height parameter. `.circular` is
// already the right style for a spinner, and a custom height means drawing the
// bar, which loses the system's Reduce Transparency and Reduce Motion
// behaviour. Revisit only if Nextcloud design signs off on losing those.
