// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import SnapshotTesting
import SwiftUI
import Testing

@testable import NextcloudUI

/// Hosts a view and compares it against its baseline.
///
/// One harness for every suite. It started as a copy per suite and three of the
/// four copies had the appearance bug below, which is the argument for one.
///
/// `ImageRenderer` is deliberately not used. It renders through SwiftUI only, so
/// `NSViewRepresentable` content, vibrancy and materials come out blank or
/// wrong -- and with Liquid Glass adopted throughout it would silently lie.
/// `.image` hosts in an `NSHostingView` and renders through AppKit, which is
/// what the reader actually sees.
///
/// Precision is loosened deliberately: exact pixel equality across runner images
/// is not achievable on AppKit, and a suite that cries wolf gets ignored.
///
/// The call site's `fileID`, `filePath`, `testName` and `line` are forwarded
/// rather than defaulted, because SnapshotTesting derives the baseline
/// directory from the file it is called in. Defaulting them here would file
/// every suite's baselines under this one.
@MainActor
func assertNCSnapshot(
    _ view: some View,
    named name: String,
    width: CGFloat,
    height: CGFloat,
    scheme: ColorScheme = .light,
    layoutDirection: LayoutDirection = .leftToRight,
    theme: NCTheme = .nextcloud,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    let hosted = NSHostingView(
        rootView:
            view
            .ncTheme(theme)
            // Both, and the second one is the one that works. An `NSHostingView`
            // with no window inherits the *process* appearance, and
            // `.preferredColorScheme` only asks a window for one -- so on a
            // machine set to dark, a suite asking for light captures the dark
            // tokens as white text on the white backdrop below, which reads as a
            // blank image rather than as a failure.
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
        as: .image(precision: 0.99, perceptualPrecision: 0.98),
        named: name,
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}
