// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import NextcloudPlatform
public import SwiftUI

/// One step in a path.
///
/// `title` is caller data and never goes through a localisation table. `id` is
/// whatever the app already uses to address a folder -- a path, a file id
/// rendered as text -- and comes back unchanged in the selection handler.
public nonisolated struct NCBreadcrumbSegment: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

/// The path trail above a Files-style browser.
///
/// The only genuinely non-native component in the navigation wave. macOS has no
/// breadcrumb control: the Finder path bar is an `NSPathControl`, which is
/// AppKit-only, file-URL-only and not themable, so none of it survives contact
/// with a remote Nextcloud tree.
///
/// When the path is wider than the space it has, the middle folds into a menu
/// and the root and the current folder stay. Which segments fold is decided by
/// ``NCBreadcrumbCollapse``, a plain function over measured widths; this view
/// measures, asks, and draws.
///
/// Every segment is a `Button`, including the current one, so tabbing reaches
/// the whole path. The pointer cursor is decoration on top of that, never the
/// only affordance.
public struct NCBreadcrumbs: View {
    private let segments: [NCBreadcrumbSegment]
    private let onSelect: (NCBreadcrumbSegment) -> Void

    @Environment(\.ncTheme) private var theme
    @Environment(\.layoutDirection) private var layoutDirection
    @State private var measured: [CGFloat] = []
    @State private var available: CGFloat = 0

    /// Creates a trail.
    ///
    /// - Parameters:
    ///   - segments: The path, root first, current folder last.
    ///   - onSelect: Called with the segment the person chose. The current
    ///     folder can be chosen too; treating that as a no-op is the caller's
    ///     job and keeps the whole path keyboard-reachable.
    public init(
        _ segments: [NCBreadcrumbSegment],
        onSelect: @escaping (NCBreadcrumbSegment) -> Void
    ) {
        self.segments = segments
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: theme.metrics.spacing.tight) {
            ForEach(Array(plan.entries.enumerated()), id: \.offset) { offset, entry in
                if offset > 0 { separator }
                switch entry {
                case .segment(let index): crumb(at: index)
                case .overflow: overflowMenu
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onGeometryChange(for: CGFloat.self) {
            $0.size.width
        } action: {
            available = $0
        }
        .background(alignment: .leading) { ruler }
        .accessibilityElement(children: .contain)
    }

    // MARK: Plan

    private var plan: NCBreadcrumbPlan {
        guard measured.count == segments.count else {
            return .allVisible(count: segments.count)
        }
        return NCBreadcrumbCollapse.plan(
            segmentWidths: measured,
            available: available,
            separatorWidth: separatorWidth,
            overflowWidth: overflowWidth
        )
    }

    /// One chevron plus the gap on either side of it.
    private var separatorWidth: CGFloat {
        theme.metrics.icon.small + theme.metrics.spacing.tight * 2
    }

    /// ponytail: the menu button's width is derived from its icon and padding
    /// rather than measured. It is off by whatever chrome the current `Menu`
    /// style adds, which costs at most one extra collapsed segment. Measure it
    /// the same way as the labels if a design review ever notices.
    private var overflowWidth: CGFloat {
        theme.metrics.icon.medium + theme.metrics.spacing.standard * 2
    }

    // MARK: Pieces

    private func crumb(at index: Int) -> some View {
        let segment = segments[index]
        let isCurrent = index == segments.count - 1
        return Button {
            onSelect(segment)
        } label: {
            label(segment, isCurrent: isCurrent)
        }
        .buttonStyle(.plain)
        .ncPointerStyle(.link)
        .accessibilityAddTraits(isCurrent ? .isSelected : [])
    }

    private var overflowMenu: some View {
        Menu {
            ForEach(plan.collapsed, id: \.self) { index in
                Button {
                    onSelect(segments[index])
                } label: {
                    Text(verbatim: segments[index].title)
                }
            }
        } label: {
            NCIcon(.dotsHorizontal, label: .decorative)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .ncPointerStyle(.link)
        .ncAccessibilityLabel(.text(LocalizedStringResource(nc: "Show hidden path components")))
    }

    private var separator: some View {
        NCIcon(.chevronRight, label: .decorative, size: .small)
            .foregroundStyle(.tertiary)
            // The chevron points along the path, so it mirrors when the path
            // runs right to left. The bundled Material asset carries no
            // directionality of its own, so the flip is explicit here rather
            // than left to the image.
            .scaleEffect(x: layoutDirection == .rightToLeft ? -1 : 1)
    }

    private func label(_ segment: NCBreadcrumbSegment, isCurrent: Bool) -> some View {
        Text(verbatim: segment.title)
            .font(.callout.weight(isCurrent ? theme.typography.heading : theme.typography.element))
            .foregroundStyle(isCurrent ? AnyShapeStyle(.primary) : AnyShapeStyle(.secondary))
            .lineLimit(1)
            .truncationMode(.middle)
            .padding(.horizontal, theme.metrics.spacing.tight)
    }

    // MARK: Measurement

    /// Every segment at its natural width, drawn behind the real trail and
    /// hidden.
    ///
    /// A background never influences the size of what it sits behind, so this
    /// buys real numbers for the collapse policy at the cost of a second layout
    /// pass and no geometry surprises. It renders every segment regardless of
    /// the plan, which is what keeps the measurement from feeding back into the
    /// plan that produced it.
    private var ruler: some View {
        HStack(spacing: 0) {
            ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
                label(segment, isCurrent: index == segments.count - 1)
                    .fixedSize()
                    .onGeometryChange(for: CGFloat.self) {
                        $0.size.width
                    } action: { width in
                        record(width, at: index)
                    }
            }
        }
        .hidden()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func record(_ width: CGFloat, at index: Int) {
        if measured.count != segments.count {
            measured = Array(repeating: 0, count: segments.count)
        }
        guard measured.indices.contains(index) else { return }
        measured[index] = width
    }
}
