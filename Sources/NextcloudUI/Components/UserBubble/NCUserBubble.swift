// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// A person named inline: avatar, display name, and whatever the caller puts
/// after it.
///
/// This is the mention affordance -- what `@lorelai` in a comment or a recipient
/// field renders as. It reads as one unit to a pointer and to VoiceOver, because
/// a mention is one thing rather than a picture next to some text.
///
/// ```swift
/// NCUserBubble(
///     displayName: "Lorelai Taylor",
///     user: "lorelai",
///     action: { openProfile("lorelai") }
/// )
/// ```
public struct NCUserBubble<Trailing: View>: View {
    private let displayName: String
    private let user: String?
    private let size: NCAvatar.Size
    private let status: NCUserStatus?
    private let load: (@Sendable () async throws -> Image)?
    private let action: (() -> Void)?
    private let trailing: Trailing

    @Environment(\.ncTheme) private var theme

    /// Creates a bubble with trailing content, usually an icon or a counter.
    ///
    /// - Parameters:
    ///   - displayName: Caller data, shown verbatim.
    ///   - user: The account id, which seeds the colour. Falls back to
    ///     `displayName`.
    ///   - size: Defaults to ``NCAvatar/Size/small``, which is the size that
    ///     sits in a line of text without changing its leading.
    ///   - status: Adds a presence badge to the avatar.
    ///   - load: Fetches the photo.
    ///   - action: Makes the whole bubble activatable -- opening a profile, or
    ///     filtering by this person. Omit it for a bubble that only labels.
    ///   - trailing: Content after the name.
    public init(
        displayName: String,
        user: String? = nil,
        size: NCAvatar.Size = .small,
        status: NCUserStatus? = nil,
        load: (@Sendable () async throws -> Image)? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.displayName = displayName
        self.user = user
        self.size = size
        self.status = status
        self.load = load
        self.action = action
        self.trailing = trailing()
    }

    public var body: some View {
        if let action {
            Button(action: action) { bubble }
                .buttonStyle(.plain)
                .ncPointerStyle(.link)
        } else {
            bubble
        }
    }

    private var bubble: some View {
        HStack(spacing: theme.metrics.spacing.tight) {
            // Decorative: the name is right there in text, and hearing it twice
            // is how a recipient list becomes unbearable on VoiceOver.
            NCAvatar(
                displayName: displayName,
                user: user,
                size: size,
                status: status,
                label: .decorative,
                load: load
            )
            Text(verbatim: displayName)
                .font(.callout.weight(theme.typography.element))
                .lineLimit(1)
                .truncationMode(.middle)
            trailing
        }
        .padding(.trailing, theme.metrics.spacing.standard)
        .padding(theme.metrics.spacing.hairline)
        .background(Capsule().fill(.quaternary))
        .accessibilityElement(children: .combine)
        .accessibilityValue(spokenStatus)
    }

    private var spokenStatus: Text {
        status.map { Text($0.accessibilityLabel) } ?? Text(verbatim: "")
    }
}

extension NCUserBubble where Trailing == EmptyView {
    /// Creates a bubble with nothing after the name.
    ///
    /// A constrained convenience initialiser, so the common call site never has
    /// to write `trailing: { EmptyView() }`.
    public init(
        displayName: String,
        user: String? = nil,
        size: NCAvatar.Size = .small,
        status: NCUserStatus? = nil,
        load: (@Sendable () async throws -> Image)? = nil,
        action: (() -> Void)? = nil
    ) {
        self.init(
            displayName: displayName,
            user: user,
            size: size,
            status: status,
            load: load,
            action: action
        ) { EmptyView() }
    }
}
