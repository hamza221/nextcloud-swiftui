// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import Foundation

/// One slot in a drawn breadcrumb trail.
public nonisolated enum NCBreadcrumbEntry: Hashable, Sendable {
    /// The segment at this index of the caller's array.
    case segment(Int)
    /// The menu holding the segments that did not fit.
    case overflow
}

/// Which breadcrumb segments are drawn and which hide behind the overflow menu.
///
/// A value, not view state: ``NCBreadcrumbs`` measures, asks
/// ``NCBreadcrumbCollapse`` for one of these, and draws it. That is what makes
/// the collapse behaviour testable without rendering anything.
public nonisolated struct NCBreadcrumbPlan: Hashable, Sendable {
    /// Indices drawn before the overflow menu.
    public let leading: [Int]
    /// Indices inside the overflow menu, in path order.
    public let collapsed: [Int]
    /// Indices drawn after the overflow menu.
    public let trailing: [Int]

    public init(leading: [Int], collapsed: [Int], trailing: [Int]) {
        self.leading = leading
        self.collapsed = collapsed
        self.trailing = trailing
    }

    /// Whether any segment is hidden.
    public var isCollapsed: Bool { !collapsed.isEmpty }

    /// The trail to draw, in reading order, separators aside.
    public var entries: [NCBreadcrumbEntry] {
        leading.map(NCBreadcrumbEntry.segment)
            + (isCollapsed ? [NCBreadcrumbEntry.overflow] : [])
            + trailing.map(NCBreadcrumbEntry.segment)
    }

    /// Nothing to draw.
    public static let empty = NCBreadcrumbPlan(leading: [], collapsed: [], trailing: [])

    /// Every segment drawn, in order.
    public static func allVisible(count: Int) -> NCBreadcrumbPlan {
        NCBreadcrumbPlan(leading: Array(0..<max(count, 0)), collapsed: [], trailing: [])
    }
}

/// The rule that decides which parts of a path stay on screen.
///
/// Plain arithmetic over measured widths, deliberately free of SwiftUI. The
/// interesting behaviour of a breadcrumb trail is entirely in the arithmetic --
/// what to drop first, what can never be dropped, what happens when nothing
/// fits -- and none of it needs a render to exercise.
public nonisolated enum NCBreadcrumbCollapse {

    /// Plans a trail.
    ///
    /// - Parameters:
    ///   - segmentWidths: Each segment's natural width, root first.
    ///   - available: The width the trail has to live in. Zero or less means
    ///     "not measured yet", which draws everything rather than nothing.
    ///   - separatorWidth: The width of one chevron plus the gaps around it.
    ///   - overflowWidth: The width of the overflow menu button.
    public static func plan(
        segmentWidths: [CGFloat],
        available: CGFloat,
        separatorWidth: CGFloat,
        overflowWidth: CGFloat
    ) -> NCBreadcrumbPlan {
        let count = segmentWidths.count

        // Under three segments there is no middle to hide. Two that do not fit
        // truncate their text instead, which still shows both ends of the path.
        guard count > 2 else { return .allVisible(count: count) }
        guard available > 0 else { return .allVisible(count: count) }

        let whole = segmentWidths.reduce(0, +) + separatorWidth * CGFloat(count - 1)
        if whole <= available { return .allVisible(count: count) }

        // Keep the root and as many segments nearest the leaf as fit: a person
        // reading a path needs where they are and where the tree starts, and the
        // steps just above the leaf are the ones they are most likely to climb.
        var tail = count - 2
        while tail > 1, !fits(tail: tail, segmentWidths, available, separatorWidth, overflowWidth) {
            tail -= 1
        }

        // Falling out of that loop at `tail == 1` means even root, menu and leaf
        // overflow. Draw them anyway: three truncated labels say more than an
        // empty bar, and the labels themselves truncate rather than clip.
        return NCBreadcrumbPlan(
            leading: [0],
            collapsed: Array(1..<(count - tail)),
            trailing: Array((count - tail)..<count)
        )
    }

    private static func fits(
        tail: Int,
        _ segmentWidths: [CGFloat],
        _ available: CGFloat,
        _ separatorWidth: CGFloat,
        _ overflowWidth: CGFloat
    ) -> Bool {
        // Separators: one after the root, one after the menu, and one between
        // each pair of kept tail segments.
        let separators = separatorWidth * CGFloat(tail + 1)
        let width = segmentWidths[0] + overflowWidth + segmentWidths.suffix(tail).reduce(0, +) + separators
        return width <= available
    }
}
