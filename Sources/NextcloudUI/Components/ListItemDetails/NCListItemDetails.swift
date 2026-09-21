// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import Foundation
public import SwiftUI

/// The metadata cluster on the trailing edge of a row: when it happened, and how
/// much of it is unread.
///
/// Mail and Talk both stack exactly this -- a relative timestamp over a count --
/// so it is one view rather than two call sites that have to agree on the
/// spacing and the alignment.
///
/// ```swift
/// NCListItemDetails(date: message.receivedAt, unreadCount: mailbox.unread)
/// ```
///
/// Both parts are optional in practice: a `nil` date and a zero count each draw
/// nothing, so a read conversation with no timestamp collapses to zero width
/// instead of leaving a gap where the cluster would be.
public struct NCListItemDetails: View {
    private let date: Date?
    private let unreadCount: Int
    private let formatter: NCRelativeDateFormatter

    @Environment(\.ncTheme) private var theme

    /// Creates a metadata cluster.
    ///
    /// - Parameters:
    ///   - date: When the item last changed. `nil` draws no timestamp.
    ///   - unreadCount: Zero draws no bubble. See ``NCCounterFormat``.
    ///   - formatter: Defaults to the abbreviated, second-free form, because a
    ///     row is narrow and a ticking second counter pulls the eye off the
    ///     subject line.
    public init(
        date: Date? = nil,
        unreadCount: Int = 0,
        formatter: NCRelativeDateFormatter = NCRelativeDateFormatter(width: .short, ignoresSeconds: true)
    ) {
        self.date = date
        self.unreadCount = unreadCount
        self.formatter = formatter
    }

    public var body: some View {
        VStack(alignment: .trailing, spacing: theme.metrics.spacing.hairline) {
            if let date {
                NCRelativeDateText(date, formatter: formatter)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    // "2 min. ago" is fine to read and poor to hear. The spoken
                    // form is the long one.
                    .accessibilityLabel(Text(verbatim: spokenFormatter.string(for: date)))
            }
            // ponytail: the bubble is always `.highlighted`, because every count
            // a Nextcloud row shows is an unread count. Take a role when
            // something needs a quiet one.
            NCCounterBubble(count: unreadCount, role: .highlighted)
        }
        // The subject line gets the slack; this cluster keeps its natural width.
        .fixedSize(horizontal: true, vertical: false)
    }

    private var spokenFormatter: NCRelativeDateFormatter {
        // ponytail: resolved once per `body`, not once per tick, so the spoken
        // string can lag the visible one by up to one refresh interval. Give
        // NCRelativeDateText a spoken-form parameter if that ever shows up in an
        // audit.
        var spoken = formatter
        spoken.width = .long
        return spoken
    }
}
