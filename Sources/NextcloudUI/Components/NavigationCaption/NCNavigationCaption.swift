// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// A sidebar section heading.
///
/// Almost all of this is `Section(header:)`, which already groups rows, sticks
/// the header while scrolling and collapses with the sidebar. What is left is
/// the part the system has no opinion about: Nextcloud's heading weight, the
/// spacing tokens, and a trailing control on the same line as the heading.
///
/// Use it as a section header rather than as a row:
///
/// ```swift
/// Section {
///     ForEach(calendars) { NCNavigationItem($0.name, icon: .calendarAccountOutline) }
/// } header: {
///     NCNavigationCaption("Calendars") {
///         Button { addCalendar() } label: { NCIcon(.plus, label: .text("Add calendar")) }
///             .buttonStyle(.plain)
///     }
/// }
/// ```
///
/// ponytail: no count, no disclosure arrow and no icon slot. A collapsible
/// section is `DisclosureGroup`, and a count next to a heading has not come up
/// in a real screen yet. Revisit when one needs it.
public struct NCNavigationCaption<Action: View>: View {
    private let title: String
    private let action: Action

    @Environment(\.ncTheme) private var theme

    /// Creates a heading with a trailing control.
    ///
    /// - Parameters:
    ///   - title: The section's name. Caller data, never localised here.
    ///   - action: The control on the heading's trailing edge, usually an add
    ///     button.
    public init(_ title: String, @ViewBuilder action: () -> Action) {
        self.title = title
        self.action = action()
    }

    public var body: some View {
        HStack(spacing: theme.metrics.spacing.tight) {
            Text(verbatim: title)
                .font(.subheadline.weight(theme.typography.heading))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
                // On the text rather than the row, so that the trailing control
                // stays its own element for VoiceOver.
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: theme.metrics.spacing.tight)
            action
        }
        .padding(.vertical, theme.metrics.spacing.hairline)
    }
}

extension NCNavigationCaption where Action == EmptyView {
    /// Creates a plain heading.
    ///
    /// A constrained convenience initialiser, so the common call site never has
    /// to write `action: { EmptyView() }`.
    public init(_ title: String) {
        self.init(title) { EmptyView() }
    }
}
