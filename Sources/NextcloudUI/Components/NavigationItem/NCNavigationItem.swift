// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import NextcloudPlatform
public import SwiftUI

/// A row in a `NavigationSplitView` sidebar: an icon, a name, a count, and the
/// actions that belong to that one item.
///
/// This is a *row*, not a navigation mechanism. Selection, the selected
/// background, the hover highlight, keyboard traversal, focus rings and the
/// sidebar's own collapse all belong to `List(selection:)`, and this view
/// deliberately implements none of them:
///
/// ```swift
/// NavigationSplitView {
///     List(selection: $mailbox) {
///         Section {
///             ForEach(mailboxes) { mailbox in
///                 NCNavigationItem(mailbox.name, icon: .email, count: mailbox.unread)
///                     .tag(mailbox.id)
///             }
///         } header: {
///             NCNavigationCaption("Mailboxes")
///         }
///     }
/// } detail: {
///     MessageList()
/// }
/// ```
///
/// Nesting is `DisclosureGroup`, which already animates, remembers its state and
/// is keyboard-operable. A hand-rolled expandable row would be a worse copy of
/// it, so there is no `children:` parameter here.
///
/// The count is an ``NCCounterBubble`` rather than `.badge(_:)`. `.badge` works
/// in a `List` and draws a quiet grey number; Nextcloud's sidebar draws a tinted
/// pill, and that difference is the whole reason this component exists.
public struct NCNavigationItem<Actions: View>: View {
    private let title: String
    private let icon: NCSymbol?
    private let count: Int
    private let actionsLabel: NCAccessibilityLabel
    private let actions: Actions

    @Environment(\.ncTheme) private var theme

    /// Creates a row with a trailing actions menu.
    ///
    /// - Parameters:
    ///   - title: The item's name. Caller data, never localised here.
    ///   - icon: The glyph before the name. Decorative: the name carries the
    ///     meaning.
    ///   - count: An unread or item count. Zero draws nothing.
    ///   - actionsLabel: How assistive technology names the actions menu.
    ///   - actions: The menu's contents -- `Button`s, `Divider`s, nested
    ///     `Menu`s.
    public init(
        _ title: String,
        icon: NCSymbol? = nil,
        count: Int = 0,
        actionsLabel: NCAccessibilityLabel = .text(LocalizedStringResource(nc: "More actions")),
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.icon = icon
        self.count = count
        self.actionsLabel = actionsLabel
        self.actions = actions()
    }

    public var body: some View {
        HStack(spacing: theme.metrics.spacing.standard) {
            if let icon {
                NCIcon(icon, label: .decorative)
            }
            Text(verbatim: title)
                .font(.body.weight(theme.typography.element))
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: theme.metrics.spacing.tight)
            NCCounterBubble(count: count)
            trailingActions
        }
        .frame(minHeight: NCPlatformMetrics.minimumHitTarget)
    }

    @ViewBuilder
    private var trailingActions: some View {
        if hasActions {
            Menu {
                actions
            } label: {
                NCIcon(.dotsHorizontal, label: .decorative)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .ncAccessibilityLabel(actionsLabel)
        }
    }

    /// `Menu` draws its button even with nothing inside it, so a row built
    /// without actions must not build one at all.
    private var hasActions: Bool { Actions.self != EmptyView.self }
}

extension NCNavigationItem where Actions == EmptyView {
    /// Creates a row with no actions menu.
    ///
    /// A constrained convenience initialiser, so the common call site never has
    /// to write `actions: { EmptyView() }`.
    public init(_ title: String, icon: NCSymbol? = nil, count: Int = 0) {
        self.init(title, icon: icon, count: count) { EmptyView() }
    }
}
