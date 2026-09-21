// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import SnapshotTesting
import SwiftUI
import Testing

@testable import NextcloudUI

/// Visual regression for the wave 1 atoms.
///
/// `ImageRenderer` is deliberately *not* used for baselines. It renders through
/// SwiftUI only, so `NSViewRepresentable` content, vibrancy and materials come
/// out blank or wrong -- and with Liquid Glass adopted throughout, it would
/// silently lie. `.image` hosts in an `NSHostingView` and renders through AppKit,
/// which is what the user actually sees.
///
/// Precision is loosened deliberately: exact pixel equality across runner images
/// is not achievable on AppKit, and a suite that cries wolf gets ignored.
@Suite("Atom snapshots", .serialized)
@MainActor
struct NCAtomSnapshotTests {
    private func assertAtom(
        _ view: some View,
        named name: String,
        width: CGFloat = 320,
        height: CGFloat = 80,
        scheme: ColorScheme = .light,
        layoutDirection: LayoutDirection = .leftToRight,
        // Without this the baseline is named after `assertAtom`, so every test
        // passing the same `named:` overwrites one file.
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        assertNCSnapshot(
            view,
            named: name,
            width: width,
            height: height,
            scheme: scheme,
            layoutDirection: layoutDirection,
            fileID: fileID,
            filePath: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }

    @Test("counter bubble roles")
    func counterBubble() {
        assertAtom(
            HStack(spacing: 12) {
                ForEach(NCCounterBubble.Role.allCases, id: \.self) { role in
                    NCCounterBubble(count: 7, role: role)
                }
            },
            named: "roles"
        )
    }

    @Test("chip roles")
    func chip() {
        assertAtom(
            VStack(alignment: .leading, spacing: 6) {
                ForEach(NCChip<EmptyView>.Role.allCases, id: \.self) { role in
                    NCChip("Lorelai Taylor", role: role)
                }
            },
            named: "roles",
            height: 180
        )
    }

    @Test("note card roles")
    func noteCard() {
        assertAtom(
            VStack(spacing: 8) {
                ForEach(NCNoteCard<Text>.Role.allCases, id: \.self) { role in
                    NCNoteCard(role, message: "Anyone with the link can edit.")
                }
            },
            named: "roles",
            width: 380,
            height: 240
        )
    }

    @Test("user status badges")
    func userStatus() {
        assertAtom(
            HStack(spacing: 12) {
                ForEach(NCUserStatus.allCases, id: \.self) { status in
                    NCUserStatusBadge(status)
                }
            },
            named: "all",
            height: 40
        )
    }
}
