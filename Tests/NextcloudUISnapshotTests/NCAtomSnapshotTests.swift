// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
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
    private let precision: Float = 0.99
    private let perceptualPrecision: Float = 0.98

    private func assertAtom(
        _ view: some View,
        named name: String,
        width: CGFloat = 320,
        height: CGFloat = 80,
        scheme: ColorScheme = .light,
        // Without this the baseline is named after `assertAtom`, so every test
        // passing `named: "roles"` overwrites the same file.
        testName: String = #function
    ) {
        // SnapshotTesting has no SwiftUI-View strategy on macOS, only NSView,
        // which is what the doc comment above wants anyway.
        let hosted = NSHostingView(
            rootView:
                view
                .ncTheme(.nextcloud)
                .preferredColorScheme(scheme)
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
