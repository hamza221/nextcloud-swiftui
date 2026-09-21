// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import NextcloudPlatform
public import SwiftUI

/// Nextcloud's icon-and-text pairing.
///
/// ```swift
/// Label {
///     Text(verbatim: mailbox.name)
/// } icon: {
///     NCIcon(.email, label: .decorative)
/// }
/// .labelStyle(.nc)
/// ```
///
/// The whole of ``NCLabelStyle/Layout/standard`` is an `HStack` at
/// `theme.metrics.spacing.tight`. SwiftUI's default label already places an icon
/// before a title, aligns it optically with the text and inherits the
/// foreground style; the only thing it does not know is Nextcloud's gap. That
/// gap is the component.
///
/// ## The icon-only variant is the accessible one
///
/// ``NCLabelStyle/Layout/iconOnly`` is `IconOnlyLabelStyle` plus a hit target.
/// That is deliberate: the system style keeps the title as the label's spoken
/// name, so a toolbar built from `Label`s stays navigable on VoiceOver while
/// showing nothing but glyphs. A bare `NCIcon` in a toolbar button does not,
/// which is why this exists as a style rather than as advice.
///
/// ```swift
/// Button(action: archive) {
///     Label {
///         Text(LocalizedStringResource(nc: "Archive"))
///     } icon: {
///         NCIcon(.folderOutline, label: .decorative)
///     }
/// }
/// .labelStyle(.ncIconOnly)
/// ```
///
/// The icon inside takes `NCAccessibilityLabel.decorative`, because the
/// title beside it is the answer and hearing it twice is how a toolbar becomes
/// unbearable.
public struct NCLabelStyle: LabelStyle {

    /// How the icon and the title sit together.
    public enum Layout: Hashable, Sendable, CaseIterable {
        /// Icon, gap, title. The default.
        case standard
        /// Icon only. The title survives as the spoken name.
        case iconOnly
    }

    private let layout: Layout

    /// Creates a style for one layout.
    ///
    /// Prefer the shorthands: `.labelStyle(.nc)` and `.labelStyle(.ncIconOnly)`.
    public init(layout: Layout) {
        self.layout = layout
    }

    public func makeBody(configuration: Configuration) -> some View {
        Rendered(layout: layout, configuration: configuration)
    }

    /// Nested for the same reason as ``NCButtonStyle``: a `LabelStyle` is not a
    /// `View`, so an `@Environment` property on it never updates.
    private struct Rendered: View {
        let layout: Layout
        let configuration: Configuration

        @Environment(\.ncTheme) private var theme

        var body: some View {
            switch layout {
            case .standard:
                // Centre rather than first-baseline alignment: every label in
                // this library pairs a glyph with one line of text, where a
                // baseline match sits the icon visibly low.
                HStack(alignment: .center, spacing: theme.metrics.spacing.tight) {
                    configuration.icon
                    configuration.title
                }
            case .iconOnly:
                // Setting the style explicitly overrides the environment, so
                // this resolves to the system style rather than recursing.
                Label(configuration)
                    .labelStyle(.iconOnly)
                    .frame(
                        minWidth: NCPlatformMetrics.minimumHitTarget,
                        minHeight: NCPlatformMetrics.minimumHitTarget
                    )
            }
        }
    }
}

extension LabelStyle where Self == NCLabelStyle {
    /// Icon, gap, title, at `theme.metrics.spacing.tight`.
    public static var nc: NCLabelStyle { NCLabelStyle(layout: .standard) }

    /// Icon only, at a full hit target, with the title kept as the spoken name.
    ///
    /// Named `ncIconOnly` rather than `iconOnly` because SwiftUI already owns
    /// that name on this protocol, and shadowing it would make every existing
    /// call site silently mean something else.
    public static var ncIconOnly: NCLabelStyle { NCLabelStyle(layout: .iconOnly) }
}

// ponytail: no title-only case and no stacked case. `.titleOnly` is a system
// style already and needs no Nextcloud gap; a stacked icon-above-title label
// belongs to an empty state, which is `ContentUnavailableView`. Add one when a
// screen asks and neither of those fits.
