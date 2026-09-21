// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import SnapshotTesting
import SwiftUI
import Testing

@testable import NextcloudUI

/// Visual regression for the wave 3 list views.
///
/// No baselines are committed with this file. They are generated only on the CI
/// runner image -- AppKit does not render deterministically across machines, and
/// a baseline recorded on a laptop differs from CI's on the next run. Comment
/// `/update-snapshots` on the pull request to record them. Until then these
/// tests fail locally with "no reference was found", which is the expected
/// state.
@Suite("List snapshots", .serialized)
@MainActor
struct NCListSnapshotTests {
    private func assertList(
        _ view: some View,
        named name: String,
        width: CGFloat = 340,
        height: CGFloat = 200,
        scheme: ColorScheme = .light,
        layoutDirection: LayoutDirection = .leftToRight,
        // Without this the baseline is named after `assertList`, so every test
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

    /// An *offset* from now rather than a fixed date, because the timestamp is
    /// relative: a fixed date renders "4 months ago" today and "5 months ago"
    /// next month, and no baseline survives that. A fixed offset lands in the
    /// same bucket on every run, so it always renders "2 min. ago".
    private static var reference: Date { .now.addingTimeInterval(-125) }

    private func mailbox() -> some View {
        List {
            NCListItem("Lorelai Taylor", subtitle: "About Friday") {
                NCIcon(.email, label: .decorative)
            } details: {
                NCListItemDetails(date: Self.reference, unreadCount: 3)
            }
            NCListItem("Tom Mörtel", subtitle: "Re: deployment window") {
                NCIcon(.email, label: .decorative)
            } details: {
                NCListItemDetails(date: Self.reference)
            }
            NCListItem("Zaki Cortes", subtitle: "Photos from the offsite") {
                NCIcon(.email, label: .decorative)
            } details: {
                NCListItemDetails(date: Self.reference, unreadCount: 128)
            }
        }
    }

    @Test("mailbox rows")
    func mailboxRows() {
        assertList(mailbox(), named: "mailbox")
    }

    @Test("mailbox rows in dark")
    func mailboxRowsDark() {
        assertList(mailbox(), named: "mailbox", scheme: .dark)
    }

    /// Long content is where a row breaks: the subject must truncate rather than
    /// push the timestamp off the trailing edge.
    @Test("long content truncates rather than squeezing the details")
    func longContent() {
        assertList(
            List {
                NCListItem(
                    "ellena.wright.frederic.conway@a-very-long-instance-name.example.com",
                    subtitle: "Re: Re: Fwd: the quarterly planning document that nobody has read"
                ) {
                    NCIcon(.accountOutline, label: .decorative)
                } details: {
                    NCListItemDetails(date: Self.reference, unreadCount: 3456)
                }
            },
            named: "longContent",
            height: 80
        )
    }

    @Test("slot combinations")
    func slots() {
        assertList(
            List {
                NCListItem("Leading only") { NCIcon(.folderOutline, label: .decorative) }
                NCListItem("Leading and trailing", subtitle: "Shared with 3 people") {
                    NCIcon(.folder, label: .decorative)
                } trailing: {
                    NCIcon(.chevronRight, label: .decorative).foregroundStyle(.tertiary)
                }
                NCListItem("Text only", subtitle: "No slots at all")
            },
            named: "slots"
        )
    }

    @Test("details cluster on its own")
    func details() {
        assertList(
            HStack(spacing: 20) {
                NCListItemDetails(date: Self.reference, unreadCount: 3)
                NCListItemDetails(date: Self.reference)
                NCListItemDetails(unreadCount: 3)
                NCListItemDetails()
            },
            named: "all",
            height: 60
        )
    }
}
