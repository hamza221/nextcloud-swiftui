// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// One row of a Nextcloud list: a mailbox message, a conversation, a file, a
/// share.
///
/// ```swift
/// List(selection: $selected) {
///     ForEach(messages) { message in
///         NCListItem(message.sender, subtitle: message.subject) {
///             NCIcon(.email, label: .decorative)
///         } details: {
///             NCListItemDetails(date: message.receivedAt, unreadCount: message.unread)
///         }
///     }
/// }
/// ```
///
/// ## This is row content, not a row
///
/// It draws no selection, no hover fill and no focus ring, because `List`
/// already does all three, correctly, with the instance's brand tint (see
/// `NCAccentPolicy`) and with the keyboard and accessibility behaviour that
/// comes with it. Hand-rolling any of that produces a row that ignores
/// `⌘`-click, loses its highlight when the window resigns key, and reads as a
/// static group to VoiceOver. Tag the row or wrap it in a `ForEach` over an
/// `Identifiable` model and pass `selection:` to the `List`.
///
/// There is no pointer cue either. macOS rows do not change the cursor, and a
/// hover-only affordance is unusable without a pointer.
///
/// ## Why one line each
///
/// The title and the subtitle both truncate at one line, and that is not
/// configurable. A mailbox is scanned vertically, which only works when every
/// row is the same height, and uniform heights are also what let `List` estimate
/// its content without measuring every row. Truncation is at the tail rather
/// than the middle as on ``NCChip``, because a subject line and a preview
/// snippet carry their meaning at the front, while an e-mail address on a chip
/// carries it at both ends.
///
/// ## Accessibility
///
/// The row combines into one element, so VoiceOver reads "Lorelai Taylor, about
/// Friday, 2 minutes ago, 3 unread" and one swipe moves to the next message
/// instead of into the row. A row takes no `NCAccessibilityLabel` because its
/// title is already text; the leading slot's content is what needs one, and
/// `NCAccessibilityLabel.decorative` is usually the honest answer there.
///
/// Combining makes a button in the trailing slot unreachable, so surface it the
/// way ``NCChip`` surfaces its remove button -- as a rotor action on the row:
///
/// ```swift
/// NCListItem(file.name) { NCIcon(.folderOutline, label: .decorative) }
///     .accessibilityActions {
///         Button(action: share) { Text(LocalizedStringResource(nc: "Share")) }
///     }
/// ```
public struct NCListItem<Leading: View, Details: View, Trailing: View>: View {
    private let title: String
    private let subtitle: String?
    private let leading: Leading
    private let details: Details
    private let trailing: Trailing

    @Environment(\.ncTheme) private var theme

    /// Creates a row with all three slots.
    ///
    /// - Parameters:
    ///   - title: Caller data. Never run through a localisation table.
    ///   - subtitle: Caller data. Blank or whitespace-only text renders no
    ///     second line at all rather than an empty one.
    ///   - leading: An avatar or an icon. The unlabelled trailing closure.
    ///   - details: The metadata cluster, usually ``NCListItemDetails``.
    ///   - trailing: A disclosure indicator, a menu button, a toggle.
    public init(
        _ title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder details: () -> Details,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading()
        self.details = details()
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: theme.metrics.spacing.standard) {
            leading
            VStack(alignment: .leading, spacing: theme.metrics.spacing.hairline) {
                Text(verbatim: NCListItemText.singleLine(title) ?? "")
                    // No explicit weight: `.fontWeight(.semibold)` applied to the
                    // whole row is how a caller marks it unread, and an explicit
                    // weight here would silently win over it.
                    .font(.body)
                    .lineLimit(1)
                if let subtitle = NCListItemText.singleLine(subtitle) {
                    Text(verbatim: subtitle)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            details
            trailing
        }
        .padding(.vertical, theme.metrics.spacing.tight)
        .accessibilityElement(children: .combine)
    }
}

extension NCListItem where Details == EmptyView, Trailing == EmptyView {
    /// Creates a row with a leading avatar or icon and nothing on the trailing
    /// side.
    public init(
        _ title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(title, subtitle: subtitle, leading: leading, details: { EmptyView() }, trailing: { EmptyView() })
    }
}

extension NCListItem where Trailing == EmptyView {
    /// Creates a row with a leading slot and a metadata cluster: the Mail and
    /// Talk shape.
    public init(
        _ title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder details: () -> Details
    ) {
        self.init(title, subtitle: subtitle, leading: leading, details: details, trailing: { EmptyView() })
    }
}

extension NCListItem where Details == EmptyView {
    /// Creates a row with a leading slot and a trailing control: the Files shape,
    /// where the trailing slot is an overflow menu.
    public init(
        _ title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.init(title, subtitle: subtitle, leading: leading, details: { EmptyView() }, trailing: trailing)
    }
}

extension NCListItem where Leading == EmptyView, Details == EmptyView, Trailing == EmptyView {
    /// Creates a text-only row.
    ///
    /// A constrained convenience initialiser, so that the common call site never
    /// has to write `leading: { EmptyView() }`.
    public init(_ title: String, subtitle: String? = nil) {
        self.init(
            title,
            subtitle: subtitle,
            leading: { EmptyView() },
            details: { EmptyView() },
            trailing: { EmptyView() }
        )
    }
}

// ponytail: five initialisers cover every slot combination that a Nextcloud
// client actually builds. The two missing ones (details without a leading slot,
// trailing without a leading slot) are deliberately absent: an unlabelled
// trailing closure would then match two overloads and the call would not
// compile. Add one only when a real screen needs it, and give it a label.
