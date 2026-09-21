// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// A person, as a circle.
///
/// Three things in order: the photo the app loads, the person's initials on a
/// colour derived from their identifier, and a generic person icon. The middle
/// step is the one that matters, because most Nextcloud accounts have no photo
/// and a wall of identical grey circles makes a message list unreadable. The
/// colour comes from `NCUsernameColor`, which agrees with the web client
/// exactly, so the same colleague is the same colour in both.
///
/// ```swift
/// NCAvatar(displayName: "Lorelai Taylor", user: "lorelai", status: .online) {
///     try await client.avatar(for: "lorelai")
/// }
/// ```
///
/// Sizes come from `theme.metrics.avatar`, so an instance that ships a denser
/// metric scale resizes every avatar at once.
public struct NCAvatar: View {
    private let displayName: String
    private let user: String?
    private let size: Size
    private let status: NCUserStatus?
    private let label: NCAccessibilityLabel
    private let load: (@Sendable () async throws -> Image)?

    @Environment(\.ncTheme) private var theme

    /// How much room the avatar takes.
    public enum Size: Hashable, Sendable, CaseIterable {
        /// Inline in a line of text, or on a chip.
        case small
        /// The default: a list row.
        case medium
        /// A message header or a card.
        case large
        /// A profile card.
        case extraLarge

        fileprivate func diameter(_ metrics: NCMetrics) -> CGFloat {
            switch self {
            case .small: metrics.avatar.small
            case .medium: metrics.avatar.medium
            case .large: metrics.avatar.large
            case .extraLarge: metrics.avatar.extraLarge
            }
        }

        /// A semantic font rather than a size derived from the diameter, so that
        /// initials follow Dynamic Type. `minimumScaleFactor` keeps them inside
        /// the circle at the largest accessibility sizes.
        fileprivate var initialsFont: Font {
            switch self {
            case .small: .caption2
            case .medium: .caption
            case .large: .callout
            case .extraLarge: .title3
            }
        }

        fileprivate var iconSize: NCIcon.Size {
            switch self {
            case .small: .small
            case .medium, .large: .medium
            case .extraLarge: .large
            }
        }
    }

    /// Creates an avatar.
    ///
    /// - Parameters:
    ///   - displayName: The person's name, as the server reports it. Caller data:
    ///     it supplies the initials and the spoken label, and never goes through
    ///     a localisation table.
    ///   - user: The account id. Seeds the colour and the cache when present,
    ///     which keeps a person's colour stable across a display-name change.
    ///     Falls back to `displayName`.
    ///   - size: Resolved against `theme.metrics.avatar`.
    ///   - status: Adds an ``NCUserStatusBadge`` overlay.
    ///   - label: Defaults to the display name, which is what an avatar means.
    ///     Pass `NCAccessibilityLabel.decorative` when the name is already
    ///     visible beside it, as in ``NCUserBubble``.
    ///   - load: Fetches the photo. Omit it for accounts with no photo, which is
    ///     most of them.
    public init(
        displayName: String,
        user: String? = nil,
        size: Size = .medium,
        status: NCUserStatus? = nil,
        label: NCAccessibilityLabel? = nil,
        load: (@Sendable () async throws -> Image)? = nil
    ) {
        self.displayName = displayName
        self.user = user
        self.size = size
        self.status = status
        self.label = label ?? .content(displayName)
        self.load = load
    }

    public var body: some View {
        photoOrFallback
            .frame(width: diameter, height: diameter)
            .clipShape(.circle)
            .overlay(alignment: .bottomTrailing) { badge }
            .accessibilityElement(children: .ignore)
            .ncAccessibilityLabel(label)
            // Presence is a property of the person, not a second element to
            // navigate to. An absent status sets an empty value, which VoiceOver
            // skips.
            .accessibilityValue(spokenStatus)
    }

    private var diameter: CGFloat { size.diameter(theme.metrics) }

    private var seed: String { user ?? displayName }

    @ViewBuilder
    private var photoOrFallback: some View {
        if let load {
            NCAsyncImage(identity: cacheIdentity, label: .decorative, load: load) { fallback }
        } else {
            fallback
        }
    }

    /// The diameter is part of the key because a caller's loader usually
    /// downsamples to the size it is asked for, and a 20pt avatar reused in a
    /// 64pt profile card would otherwise render blurred.
    private var cacheIdentity: String {
        seed.isEmpty ? "" : "\(seed)@\(Int(diameter))"
    }

    private var fallback: some View {
        Circle()
            .fill(NCUsernameColor.color(for: seed))
            .overlay { initialsOrIcon }
            .foregroundStyle(contrastingForeground)
    }

    @ViewBuilder
    private var initialsOrIcon: some View {
        let initials = NCAvatarInitials.initials(for: displayName)
        if initials.isEmpty {
            NCIcon(.accountOutline, label: .decorative, size: size.iconSize)
        } else {
            Text(verbatim: initials)
                .font(size.initialsFont.weight(theme.typography.heading))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }

    /// White or black, whichever reads better on this person's colour. The
    /// palette spans gold to deep purple, so a fixed white would fail contrast
    /// on a third of it.
    private var contrastingForeground: Color {
        NCContrast.preferredForeground(on: NCUsernameColor.rgb(for: seed)).color
    }

    @ViewBuilder
    private var badge: some View {
        if let status {
            // ponytail: the badge is a fixed `theme.metrics.icon.small`, so it
            // is heavy on a 20pt avatar. Give NCUserStatusBadge a size the first
            // time a small avatar ships with presence.
            NCUserStatusBadge(status, label: .decorative)
                .padding(theme.metrics.spacing.hairline)
                // The ring separates the dot from a photo of a similar colour.
                .background(Circle().fill(.background))
        }
    }

    private var spokenStatus: Text {
        status.map { Text($0.accessibilityLabel) } ?? Text(verbatim: "")
    }
}
