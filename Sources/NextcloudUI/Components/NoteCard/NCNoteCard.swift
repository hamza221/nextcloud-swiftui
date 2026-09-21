// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// An inline banner.
///
/// Distinct from `.alert`, and deliberately so: an alert interrupts and demands
/// dismissal, while a note card sits in the flow and explains. Using a modal for
/// something that is merely informational is the most common way a settings pane
/// becomes unusable.
public struct NCNoteCard<Content: View>: View {
    private let role: Role
    private let title: LocalizedStringResource?
    private let content: Content

    @Environment(\.ncTheme) private var theme

    /// What the banner is telling the reader.
    public enum Role: Hashable, Sendable, CaseIterable {
        case info
        case success
        case warning
        case error

        /// Spoken before the content, because the colour alone says nothing to a
        /// screen reader and the icon is decorative.
        public var accessibilityLabel: LocalizedStringResource {
            switch self {
            case .info: LocalizedStringResource(nc: "Information")
            case .success: LocalizedStringResource(nc: "Success")
            case .warning: LocalizedStringResource(nc: "Warning")
            case .error: LocalizedStringResource(nc: "Error")
            }
        }

        fileprivate var symbol: NCSymbol {
            switch self {
            case .info: .helpCircle
            case .success: .checkboxMarkedCircleOutline
            case .warning: .alertOctagonOutline
            case .error: .alertOctagonOutline
            }
        }

        fileprivate func colours(_ tokens: NCColorTokens) -> NCStatusColors {
            switch self {
            case .info: tokens.info
            case .success: tokens.success
            case .warning: tokens.warning
            case .error: tokens.error
            }
        }
    }

    public init(
        _ role: Role,
        title: LocalizedStringResource? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.role = role
        self.title = title
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.metrics.spacing.standard) {
            NCIcon(role.symbol, label: .decorative)
                .foregroundStyle(colours.element)
            VStack(alignment: .leading, spacing: theme.metrics.spacing.tight) {
                if let title {
                    Text(title).font(.headline.weight(theme.typography.heading))
                }
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(theme.metrics.spacing.comfortable)
        .foregroundStyle(colours.onSurface)
        .background(
            RoundedRectangle(cornerRadius: theme.metrics.radius.element)
                .fill(colours.surface)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(role.accessibilityLabel))
    }

    private var colours: NCStatusColors { role.colours(theme.colors) }
}

extension NCNoteCard where Content == Text {
    /// Creates a banner with a plain message.
    public init(_ role: Role, title: LocalizedStringResource? = nil, message: LocalizedStringResource) {
        self.init(role, title: title) { Text(message) }
    }
}
