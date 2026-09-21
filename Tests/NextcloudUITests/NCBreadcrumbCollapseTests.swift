// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing

@testable import NextcloudUI

@Suite("Breadcrumb collapse")
struct NCBreadcrumbCollapseTests {

    /// Uniform 100pt segments, a 20pt separator and a 40pt menu, so that every
    /// expectation below is arithmetic a reader can redo in their head.
    private func plan(
        count: Int,
        available: CGFloat,
        width: CGFloat = 100,
        separator: CGFloat = 20,
        overflow: CGFloat = 40
    ) -> NCBreadcrumbPlan {
        NCBreadcrumbCollapse.plan(
            segmentWidths: Array(repeating: width, count: count),
            available: available,
            separatorWidth: separator,
            overflowWidth: overflow
        )
    }

    // MARK: Degenerate inputs

    @Test("no segments draws nothing")
    func noSegments() {
        let result = plan(count: 0, available: 400)
        #expect(result == .empty)
        #expect(result.entries.isEmpty)
        #expect(!result.isCollapsed)
    }

    /// A single segment is the root and the leaf at once, so there is nothing
    /// that may be dropped however little room there is. It truncates instead.
    @Test("one segment never collapses", arguments: [1000.0, 10.0, 0.0])
    func oneSegment(available: CGFloat) {
        let result = plan(count: 1, available: available)
        #expect(result.entries == [.segment(0)])
        #expect(!result.isCollapsed)
    }

    /// Two segments are root and leaf, and collapsing would have to hide one of
    /// them. Both ends of a path are worth more than a tidy width.
    @Test("two segments never collapse even when they do not fit")
    func twoSegments() {
        let result = plan(count: 2, available: 30)
        #expect(result.entries == [.segment(0), .segment(1)])
    }

    /// Every label wider than the whole bar. Root, menu and leaf go out anyway:
    /// three truncated labels say more than an empty bar.
    @Test("collapses to root and leaf when nothing fits")
    func nothingFits() {
        let result = plan(count: 4, available: 100, width: 1000)
        #expect(result.leading == [0])
        #expect(result.collapsed == [1, 2])
        #expect(result.trailing == [3])
        #expect(result.entries == [.segment(0), .overflow, .segment(3)])
    }

    /// Before the first layout pass the bar has no width. Drawing everything and
    /// letting the next pass collapse it beats drawing nothing.
    @Test("an unmeasured width draws everything", arguments: [0.0, -1.0])
    func unmeasured(available: CGFloat) {
        let result = plan(count: 6, available: available)
        #expect(!result.isCollapsed)
        #expect(result.leading == [0, 1, 2, 3, 4, 5])
    }

    // MARK: Fitting

    /// 5 x 100 plus 4 x 20 separators is 580.
    @Test("draws the whole path when it fits")
    func wholePathFits() {
        #expect(!plan(count: 5, available: 580).isCollapsed)
        #expect(plan(count: 5, available: 580).entries.count == 5)
    }

    @Test("collapses as soon as the whole path is one point too wide")
    func collapsesJustOver() {
        #expect(plan(count: 5, available: 579).isCollapsed)
    }

    /// Root 100 + menu 40 + two kept 200 + three separators 60 is 400.
    @Test("keeps the segments nearest the leaf")
    func keepsTheLeafEnd() {
        let result = plan(count: 5, available: 400)
        #expect(result.leading == [0])
        #expect(result.collapsed == [1, 2])
        #expect(result.trailing == [3, 4])
    }

    /// Root 100 + menu 40 + three kept 300 + four separators 80 is 520, so one
    /// more point of room keeps one more segment.
    @Test("keeps as many segments as fit")
    func keepsAsManyAsFit() {
        #expect(plan(count: 5, available: 520).collapsed == [1])
        #expect(plan(count: 5, available: 519).collapsed == [1, 2])
    }

    @Test("counts the separators and the menu, not just the labels")
    func countsChrome() {
        // Labels alone are 500, which fits in 500; the chrome is what pushes it
        // over.
        #expect(plan(count: 5, available: 500, separator: 0, overflow: 0).isCollapsed == false)
        #expect(plan(count: 5, available: 500, separator: 20, overflow: 40).isCollapsed)
    }

    /// Segments are not uniform in practice, so the decision has to be driven by
    /// each label's own width rather than by a count.
    @Test("measures each segment rather than assuming one width")
    func unevenWidths() {
        let result = NCBreadcrumbCollapse.plan(
            // A very wide second segment is what forces the collapse.
            segmentWidths: [60, 400, 60, 60],
            available: 300,
            separatorWidth: 10,
            overflowWidth: 30
        )
        // 60 + 30 + (60 + 60) + 3 x 10 = 240 fits, so both tail segments stay.
        #expect(result.leading == [0])
        #expect(result.collapsed == [1])
        #expect(result.trailing == [2, 3])
    }

    // MARK: Plan shape

    @Test("entries put the menu between the root and the kept tail")
    func entryOrder() {
        #expect(
            plan(count: 5, available: 400).entries == [
                .segment(0), .overflow, .segment(3), .segment(4),
            ]
        )
    }

    @Test("an uncollapsed plan has no overflow entry")
    func noOverflowWhenUncollapsed() {
        #expect(!NCBreadcrumbPlan.allVisible(count: 3).entries.contains(.overflow))
    }

    @Test("allVisible of zero is empty")
    func allVisibleOfZero() {
        #expect(NCBreadcrumbPlan.allVisible(count: 0) == .empty)
    }
}
