// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// The large identity surface: who this is, a few lines about them, and what you
/// can do about it.
///
/// What goes in a popover from an ``NCUserBubble``, or at the head of a contact
/// detail pane. The secondary lines are caller data in the order the caller wants
/// them -- a role, an email address, a status message -- rather than named slots,
/// because every Nextcloud app has a different set and an absent one should
/// close the gap rather than leave a hole.
///
/// ```swift
/// NCProfileCard(
///     displayName: "Lorelai Taylor",
///     user: "lorelai",
///     status: .online,
///     secondaryLines: ["Product design", "lorelai@example.com"]
/// ) {
///     Button("Send message") { compose(to: "lorelai") }
/// }
/// ```
public struct NCProfileCard<Actions: View>: View {
    private let displayName: String
    private let user: String?
    private let status: NCUserStatus?
    private let secondaryLines: [String]
    private let load: (@Sendable () async throws -> Image)?
    private let actions: Actions

    @Environment(\.ncTheme) private var theme

    /// Creates a profile card with an action area.
    ///
    /// - Parameters:
    ///   - displayName: Caller data, shown verbatim.
    ///   - user: The account id, which seeds the colour. Falls back to
    ///     `displayName`.
    ///   - status: Adds a presence badge to the avatar.
    ///   - secondaryLines: Caller data, shown in order under the name. Blank
    ///     entries are dropped, so a caller can pass an optional field through
    ///     without filtering first.
    ///   - load: Fetches the photo.
    ///   - actions: Buttons under the card. Usually one or two.
    public init(
        displayName: String,
        user: String? = nil,
        status: NCUserStatus? = nil,
        secondaryLines: [String] = [],
        load: (@Sendable () async throws -> Image)? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.displayName = displayName
        self.user = user
        self.status = status
        self.secondaryLines = secondaryLines.filter { $0.contains { !$0.isWhitespace } }
        self.load = load
        self.actions = actions()
    }

    public var body: some View {
        VStack(spacing: theme.metrics.spacing.standard) {
            NCAvatar(
                displayName: displayName,
                user: user,
                size: .extraLarge,
                status: status,
                label: .decorative,
                load: load
            )
            identity
            actions
        }
        .padding(theme.metrics.spacing.loose)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: theme.metrics.radius.container)
                .fill(.quaternary)
        )
    }

    private var identity: some View {
        VStack(spacing: theme.metrics.spacing.hairline) {
            Text(verbatim: displayName)
                .font(.headline.weight(theme.typography.heading))
                .multilineTextAlignment(.center)
            // Keyed by position rather than by value: two identical lines are
            // unusual but not impossible, and `id: \.self` would collapse them.
            ForEach(Array(secondaryLines.enumerated()), id: \.offset) { _, line in
                Text(verbatim: line)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        // The name and its detail lines are one thing to hear. The actions stay
        // outside so they remain reachable.
        .accessibilityElement(children: .combine)
        .accessibilityValue(spokenStatus)
    }

    private var spokenStatus: Text {
        status.map { Text($0.accessibilityLabel) } ?? Text(verbatim: "")
    }
}

extension NCProfileCard where Actions == EmptyView {
    /// Creates a profile card with no actions.
    ///
    /// A constrained convenience initialiser, so the common call site never has
    /// to write `actions: { EmptyView() }`.
    public init(
        displayName: String,
        user: String? = nil,
        status: NCUserStatus? = nil,
        secondaryLines: [String] = [],
        load: (@Sendable () async throws -> Image)? = nil
    ) {
        self.init(
            displayName: displayName,
            user: user,
            status: status,
            secondaryLines: secondaryLines,
            load: load
        ) { EmptyView() }
    }
}
