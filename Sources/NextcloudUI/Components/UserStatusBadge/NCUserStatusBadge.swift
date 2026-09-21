// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// A person's presence.
public nonisolated enum NCUserStatus: Hashable, Sendable, CaseIterable {
    case online
    case away
    /// In a meeting or on a call. Renders like ``doNotDisturb`` but means
    /// something different, and upstream keeps them distinct.
    case busy
    case doNotDisturb
    /// Chose to appear offline.
    case invisible
    /// Actually offline.
    case offline

    /// The spoken description.
    ///
    /// Presence is conveyed by colour and shape, so it must be conveyed by text
    /// too -- this is the whole accessibility story for the badge.
    public var accessibilityLabel: LocalizedStringResource {
        switch self {
        case .online: LocalizedStringResource(nc: "Online")
        case .away: LocalizedStringResource(nc: "Away")
        case .busy: LocalizedStringResource(nc: "Busy")
        case .doNotDisturb: LocalizedStringResource(nc: "Do not disturb")
        case .invisible: LocalizedStringResource(nc: "Invisible")
        case .offline: LocalizedStringResource(nc: "Offline")
        }
    }

    internal func tint(_ colours: NCUserStatusColors) -> NCDynamicColor {
        switch self {
        case .online: colours.online
        case .away: colours.away
        case .busy, .doNotDisturb: colours.busy
        case .invisible, .offline: colours.offline
        }
    }
}

/// A presence indicator.
///
/// Each status has a distinct *shape* as well as a distinct colour: a filled
/// circle, a crescent, a dash, a ring. Colour alone would leave the badge
/// meaningless to a red-green colourblind reader, which is roughly one man in
/// twelve.
public struct NCUserStatusBadge: View {
    private let status: NCUserStatus
    private let label: NCAccessibilityLabel

    @Environment(\.ncTheme) private var theme

    /// Creates a badge.
    ///
    /// - Parameters:
    ///   - status: The presence to show.
    ///   - label: Defaults to the status's own spoken name. Pass
    ///     `NCAccessibilityLabel.decorative` when overlaid on an avatar that
    ///     already appends the status to its label.
    public init(_ status: NCUserStatus, label: NCAccessibilityLabel? = nil) {
        self.status = status
        self.label = label ?? .text(status.accessibilityLabel)
    }

    public var body: some View {
        shape
            .foregroundStyle(status.tint(theme.colors.userStatus))
            .frame(width: dotSize, height: dotSize)
            .ncAccessibilityLabel(label)
    }

    private var dotSize: CGFloat { theme.metrics.icon.small }

    @ViewBuilder
    private var shape: some View {
        switch status {
        case .online:
            Circle()
        case .away:
            // A half disc, echoing the web's crescent.
            Circle().trim(from: 0.25, to: 0.75)
        case .busy, .doNotDisturb:
            Circle().overlay {
                Capsule()
                    .fill(.background)
                    .frame(width: dotSize * 0.5, height: dotSize * 0.2)
            }
        case .invisible, .offline:
            Circle().strokeBorder(lineWidth: dotSize * 0.2)
        }
    }
}
