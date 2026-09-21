// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import SnapshotTesting
import SwiftUI
import Testing

@testable import NextcloudUI

/// Visual regression for the wave 4 navigation components.
///
/// No baselines are committed with this file. They are recorded on the pinned CI
/// runner image only -- AppKit does not render identically across machines, and a
/// laptop-recorded baseline turns the suite into noise. Comment
/// `/update-snapshots` on the pull request to record them. Until then these
/// tests fail locally with "no reference was found", which is the expected
/// state.
@Suite("Navigation snapshots", .serialized)
@MainActor
struct NCNavigationSnapshotTests {
    private let precision: Float = 0.99
    private let perceptualPrecision: Float = 0.98

    private func assertNavigation(
        _ view: some View,
        named name: String,
        width: CGFloat = 320,
        height: CGFloat = 80,
        scheme: ColorScheme = .light,
        layoutDirection: LayoutDirection = .leftToRight,
        // Without this the baseline is named after `assertNavigation`, so every
        // test passing `named: "default"` overwrites the same file.
        testName: String = #function
    ) {
        let hosted = NSHostingView(
            rootView:
                view
                .ncTheme(.nextcloud)
                // Both, and the second one is the one that works. An
                // `NSHostingView` with no window inherits the *process*
                // appearance, and `.preferredColorScheme` only asks the window
                // for one -- so on a machine set to dark, a suite asking for
                // light captures the dark tokens as white text on the white
                // backdrop below, which reads as a blank image rather than as a
                // failure.
                .preferredColorScheme(scheme)
                .environment(\.colorScheme, scheme)
                .environment(\.layoutDirection, layoutDirection)
                .frame(width: width, height: height)
                .background(Color.white)
        )
        hosted.frame = CGRect(x: 0, y: 0, width: width, height: height)
        hosted.layoutSubtreeIfNeeded()

        assertSnapshot(
            of: hosted,
            as: .image(precision: precision, perceptualPrecision: perceptualPrecision),
            named: name,
            testName: testName
        )
    }

    private var path: [NCBreadcrumbSegment] {
        [
            NCBreadcrumbSegment(id: "/", title: "Files"),
            NCBreadcrumbSegment(id: "/work", title: "Work"),
            NCBreadcrumbSegment(id: "/work/2026", title: "2026"),
            NCBreadcrumbSegment(id: "/work/2026/q3", title: "Q3"),
            NCBreadcrumbSegment(id: "/work/2026/q3/reports", title: "Reports"),
        ]
    }

    @Test("navigation item rows")
    func navigationItem() {
        assertNavigation(
            VStack(alignment: .leading, spacing: 4) {
                NCNavigationItem("Inbox", icon: .email, count: 12)
                NCNavigationItem("Drafts", icon: .pencilOutline, count: 2)
                NCNavigationItem("All accounts")
            },
            named: "rows",
            height: 120
        )
    }

    @Test("navigation item with an actions menu")
    func navigationItemActions() {
        assertNavigation(
            NCNavigationItem("Inbox", icon: .email, count: 12) {
                Button {
                } label: {
                    Text(verbatim: "Rename")
                }
            },
            named: "actions",
            height: 40
        )
    }

    @Test("navigation caption")
    func navigationCaption() {
        assertNavigation(
            VStack(alignment: .leading, spacing: 8) {
                NCNavigationCaption("Mailboxes")
                NCNavigationCaption("Calendars") {
                    Button {
                    } label: {
                        NCIcon(.plus, label: .decorative)
                    }
                    .buttonStyle(.plain)
                }
            },
            named: "headings",
            height: 80
        )
    }

    /// Wide enough for the whole path, so this is the uncollapsed baseline.
    @Test("breadcrumbs at full width")
    func breadcrumbsFull() {
        assertNavigation(NCBreadcrumbs(path) { _ in }, named: "full", width: 440, height: 40)
    }

    /// The collapse is the behaviour worth a picture: root, menu, two segments.
    @Test("breadcrumbs collapsed")
    func breadcrumbsCollapsed() {
        assertNavigation(NCBreadcrumbs(path) { _ in }, named: "collapsed", width: 220, height: 40)
    }

    @Test("breadcrumbs right to left")
    func breadcrumbsRTL() {
        assertNavigation(
            NCBreadcrumbs([
                NCBreadcrumbSegment(id: "/", title: "الملفات"),
                NCBreadcrumbSegment(id: "/work", title: "العمل"),
                NCBreadcrumbSegment(id: "/work/reports", title: "التقارير"),
            ]) { _ in },
            named: "rtl",
            height: 40,
            layoutDirection: .rightToLeft
        )
    }
}
