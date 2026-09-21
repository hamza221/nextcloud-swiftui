// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// An unread or item count.
///
/// SwiftUI's `.badge` exists, but it only takes effect inside a `List`, a
/// `TabView` or a menu, and it cannot be restyled or placed. Nextcloud puts
/// counts on navigation rows, next to headings and inside chips, so this is a
/// view rather than a modifier.
public struct NCCounterBubble: View {
    private let count: Int
    private let role: Role
    private let limit: Int
    private let label: NCAccessibilityLabel

    @Environment(\.ncTheme) private var theme

    /// How much attention the count draws.
    public enum Role: Hashable, Sendable, CaseIterable {
        /// The default: quiet, for a count that is informational.
        case neutral
        /// Filled with the instance's brand colour, for unread items.
        case highlighted
        /// Outlined, for a count on an already-tinted surface.
        case outlined
    }

    /// Creates a counter.
    ///
    /// - Parameters:
    ///   - count: The number to show. Zero renders nothing at all.
    ///   - role: How much attention it draws.
    ///   - limit: The largest number shown exactly; above it, `"99+"`.
    ///   - label: How assistive technology describes it. Defaults to a spoken
    ///     unread count, which is right in the common case; pass
    ///     ``NCAccessibilityLabel/decorative`` when the surrounding row already
    ///     says it.
    public init(
        count: Int,
        role: Role = .neutral,
        limit: Int = NCCounterFormat.defaultLimit,
        label: NCAccessibilityLabel? = nil
    ) {
        self.count = count
        self.role = role
        self.limit = limit
        self.label = label ?? .text(LocalizedStringResource(nc: "\(count) unread"))
    }

    public var body: some View {
        if NCCounterFormat.isVisible(count) {
            Text(verbatim: NCCounterFormat.text(for: count, limit: limit))
                .font(.caption.weight(theme.typography.element))
                .monospacedDigit()
                .lineLimit(1)
                .padding(.horizontal, theme.metrics.spacing.tight)
                .padding(.vertical, theme.metrics.spacing.hairline)
                .frame(minWidth: theme.metrics.icon.medium)
                .foregroundStyle(foreground)
                .background(background)
                .overlay(border)
                .ncAccessibilityLabel(label)
        }
    }

    @ViewBuilder
    private var background: some View {
        switch role {
        case .neutral: Capsule().fill(.quaternary)
        case .highlighted: Capsule().fill(theme.colors.primary)
        case .outlined: Capsule().fill(.clear)
        }
    }

    @ViewBuilder
    private var border: some View {
        if role == .outlined {
            Capsule().strokeBorder(.tertiary)
        }
    }

    private var foreground: AnyShapeStyle {
        switch role {
        case .neutral, .outlined: AnyShapeStyle(.secondary)
        case .highlighted: AnyShapeStyle(theme.colors.onPrimary)
        }
    }
}
