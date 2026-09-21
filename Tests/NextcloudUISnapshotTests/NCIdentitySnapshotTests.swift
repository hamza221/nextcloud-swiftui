// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import SnapshotTesting
import SwiftUI
import Testing

@testable import NextcloudUI

/// Visual regression for the wave 2 identity components.
///
/// Every case here renders the fallback path -- initials on a generated colour --
/// rather than a loaded photo. A loader resolves on a task, so a snapshot taken
/// synchronously would race it, and the fallback is the state that most
/// Nextcloud accounts are in anyway.
///
/// No baselines are committed with this file. They are recorded on the pinned CI
/// runner image only: AppKit does not render identically across machines, so a
/// locally recorded baseline differs from CI's on the next run and the usual
/// response destroys the signal. Comment `/update-snapshots` on the pull request
/// to record them.
@Suite("Identity snapshots", .serialized)
@MainActor
struct NCIdentitySnapshotTests {
    private func assertIdentity(
        _ view: some View,
        named name: String,
        width: CGFloat = 320,
        height: CGFloat = 96,
        scheme: ColorScheme = .light,
        layoutDirection: LayoutDirection = .leftToRight,
        // Without this the baseline is named after `assertIdentity`, so every test
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

    @Test("avatar sizes")
    func avatarSizes() {
        assertIdentity(
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(NCAvatar.Size.allCases, id: \.self) { size in
                    NCAvatar(displayName: "Lorelai Taylor", user: "lorelai", size: size)
                }
            },
            named: "sizes"
        )
    }

    /// One-word, multi-word, non-Latin and emoji-leading names side by side. A
    /// regression here is usually a clipped or vertically off-centre glyph,
    /// which no unit test on ``NCAvatarInitials`` can see.
    @Test("avatar fallback names")
    func avatarNames() {
        assertIdentity(
            HStack(spacing: 8) {
                ForEach(["Lorelai Taylor", "Cher", "田中 太郎", "محمد علي", "🎉", ""], id: \.self) {
                    name in
                    NCAvatar(displayName: name, size: .large)
                }
            },
            named: "names",
            width: 360
        )
    }

    @Test("avatar with a status badge")
    func avatarStatus() {
        assertIdentity(
            HStack(spacing: 12) {
                ForEach(NCUserStatus.allCases, id: \.self) { status in
                    NCAvatar(displayName: "Tom Mörtel", user: "tom", size: .large, status: status)
                }
            },
            named: "status",
            width: 360
        )
    }

    @Test("user bubble")
    func userBubble() {
        assertIdentity(
            VStack(alignment: .leading, spacing: 8) {
                NCUserBubble(displayName: "Lorelai Taylor", user: "lorelai")
                NCUserBubble(displayName: "Zaki Cortes", user: "zaki", status: .online)
            },
            named: "default",
            height: 80
        )
    }

    @Test("profile card")
    func profileCard() {
        assertIdentity(
            NCProfileCard(
                displayName: "Lorelai Taylor",
                user: "lorelai",
                status: .online,
                secondaryLines: ["Product design", "lorelai@example.com"]
            ) {
                Button(action: {}) { Text(verbatim: "Send message") }
            },
            named: "default",
            width: 280,
            height: 280
        )
    }
}
