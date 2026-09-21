// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// A compact token representing one selected thing: a recipient, a tag, a
/// filter.
///
/// Note what this does *not* take: a colour. `NCChip(text:backgroundColor:)`
/// would make every call site responsible for staying consistent with the design
/// system, and they will not. A ``Role`` names the meaning and the system picks
/// the colour. The exception is data that genuinely carries its own colour -- a
/// calendar, a tag -- which is what ``tint`` is for.
public struct NCChip<Leading: View>: View {
    private let text: String
    private let role: Role
    private let tint: NCDynamicColor?
    private let onRemove: (() -> Void)?
    private let leading: Leading

    @Environment(\.ncTheme) private var theme

    /// What a chip means.
    public enum Role: Hashable, Sendable, CaseIterable {
        /// The default.
        case neutral
        /// Selected, or belonging to this instance.
        case primary
        case success
        case warning
        case error
    }

    /// Creates a chip with leading content, usually an avatar or an icon.
    public init(
        _ text: String,
        role: Role = .neutral,
        tint: NCDynamicColor? = nil,
        onRemove: (() -> Void)? = nil,
        @ViewBuilder leading: () -> Leading
    ) {
        self.text = text
        self.role = role
        self.tint = tint
        self.onRemove = onRemove
        self.leading = leading()
    }

    public var body: some View {
        HStack(spacing: theme.metrics.spacing.tight) {
            leading
            Text(verbatim: text)
                .font(.callout.weight(theme.typography.element))
                .lineLimit(1)
                .truncationMode(.middle)
            removeButton
        }
        .padding(.horizontal, theme.metrics.spacing.standard)
        .padding(.vertical, theme.metrics.spacing.tight)
        .foregroundStyle(foreground)
        .background(Capsule().fill(background))
        // VoiceOver reads the chip as one thing, not as an avatar, then a name,
        // then a button. Combining children makes the remove button
        // unreachable, so removal comes back as a rotor action -- which is also
        // the better interaction: one swipe instead of navigating into the chip.
        .accessibilityElement(children: .combine)
        .accessibilityRemoveAction(named: removeActionLabel, perform: onRemove)
    }

    private var removeActionLabel: Text {
        Text(LocalizedStringResource(nc: "Remove \(text)"))
    }

    @ViewBuilder
    private var removeButton: some View {
        if let onRemove {
            Button(action: onRemove) {
                NCIcon(.close, label: .decorative, size: .small)
            }
            .buttonStyle(.plain)
            .ncPointerStyle(.link)
            // Surfaced as an accessibility action on the chip itself instead.
            .accessibilityHidden(true)
        }
    }

    private var background: AnyShapeStyle {
        if let tint { return AnyShapeStyle(tint.opacity(0.18)) }
        switch role {
        case .neutral: return AnyShapeStyle(.quaternary)
        case .primary: return AnyShapeStyle(theme.colors.primarySurface)
        case .success: return AnyShapeStyle(theme.colors.success.surface)
        case .warning: return AnyShapeStyle(theme.colors.warning.surface)
        case .error: return AnyShapeStyle(theme.colors.error.surface)
        }
    }

    private var foreground: AnyShapeStyle {
        if tint != nil { return AnyShapeStyle(.primary) }
        switch role {
        case .neutral: return AnyShapeStyle(.primary)
        case .primary: return AnyShapeStyle(theme.colors.onPrimarySurface)
        case .success: return AnyShapeStyle(theme.colors.success.onSurface)
        case .warning: return AnyShapeStyle(theme.colors.warning.onSurface)
        case .error: return AnyShapeStyle(theme.colors.error.onSurface)
        }
    }
}

extension NCChip where Leading == EmptyView {
    /// Creates a chip with no leading content.
    ///
    /// A constrained convenience initialiser, so that the common call site never
    /// has to write `leading: { EmptyView() }`.
    public init(
        _ text: String,
        role: Role = .neutral,
        tint: NCDynamicColor? = nil,
        onRemove: (() -> Void)? = nil
    ) {
        self.init(text, role: role, tint: tint, onRemove: onRemove) { EmptyView() }
    }
}

extension View {
    /// Adds a named accessibility action when a handler is present.
    ///
    /// Factored out because `.accessibilityAction` has no optional-handler form,
    /// and an inline `if` around a modifier changes the view's identity.
    fileprivate func accessibilityRemoveAction(
        named label: Text,
        perform action: (() -> Void)?
    ) -> some View {
        accessibilityActions {
            if let action {
                Button(action: action) { label }
            }
        }
    }
}
