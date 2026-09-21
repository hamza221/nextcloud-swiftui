// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import SnapshotTesting
import SwiftUI
import Testing

@testable import NextcloudUI

/// Visual regression for the wave 5 input views and styles.
///
/// No baselines are committed with this file. They are generated only on the CI
/// runner image -- AppKit does not render deterministically across machines, and
/// a baseline recorded on a laptop differs from CI's on the next run. Comment
/// `/update-snapshots` on the pull request to record them. Until then these
/// tests fail locally with "no reference was found", which is the expected
/// state.
///
/// The styles are worth a baseline even though each one is a system style plus a
/// tint, because that is exactly what a macOS point release changes underneath
/// us. A diff here is the signal that Apple moved, not that we did.
@Suite("Input snapshots", .serialized)
@MainActor
struct NCInputSnapshotTests {
    private let precision: Float = 0.99
    private let perceptualPrecision: Float = 0.98

    private func assertInput(
        _ view: some View,
        named name: String,
        width: CGFloat = 320,
        height: CGFloat = 200,
        scheme: ColorScheme = .light,
        theme: NCTheme = .nextcloud,
        // Without this the baseline is named after `assertInput`, so every test
        // passing `named: "default"` overwrites the same file.
        testName: String = #function
    ) {
        let hosted = NSHostingView(
            rootView:
                view
                .ncTheme(theme)
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

    // MARK: Button styles

    private func buttonRoles() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {}) { Text(verbatim: "Send") }
                .buttonStyle(.primary)
            Button(action: {}) { Text(verbatim: "Save draft") }
                .buttonStyle(.secondary)
            Button(action: {}) { Text(verbatim: "Cancel") }
                .buttonStyle(.tertiary)
            Button(role: .destructive, action: {}) { Text(verbatim: "Delete") }
                .buttonStyle(.error)
            Button(action: {}) {
                Label {
                    Text(verbatim: "Archive")
                } icon: {
                    NCIcon(.folderOutline, label: .decorative)
                }
            }
            .buttonStyle(.icon)
        }
    }

    @Test("button roles")
    func buttonRolesLight() {
        assertInput(buttonRoles(), named: "roles")
    }

    @Test("button roles in dark")
    func buttonRolesDark() {
        assertInput(buttonRoles(), named: "roles", scheme: .dark)
    }

    /// The brand must reach the filled roles and must not reach the error role,
    /// which is a status token rather than branding.
    @Test("button roles under instance branding")
    func buttonRolesBranded() {
        assertInput(
            buttonRoles(),
            named: "roles",
            theme: NCTheme(brand: NCBrand(primaryHex: "#aa0055") ?? .nextcloud)
        )
    }

    /// Under this policy the style passes no tint, so the buttons take the
    /// runner's system accent instead of Nextcloud blue.
    @Test("button roles under the system accent policy")
    func buttonRolesSystemAccent() {
        assertInput(
            buttonRoles(),
            named: "roles",
            theme: NCTheme(accentPolicy: .system)
        )
    }

    @Test("a button label longer than its container truncates")
    func buttonLongContent() {
        assertInput(
            VStack(spacing: 12) {
                Button(action: {}) {
                    Text(verbatim: "Send to everyone in the quarterly planning distribution list")
                }
                .buttonStyle(.primary)
                Button(action: {}) { Text(verbatim: "Cancel") }
                    .buttonStyle(.tertiary)
                    .disabled(true)
            }
            .frame(width: 200),
            named: "longContent",
            height: 120
        )
    }

    // MARK: Label style

    @Test("label layouts")
    func labelLayouts() {
        assertInput(
            VStack(alignment: .leading, spacing: 12) {
                Label {
                    Text(verbatim: "Inbox")
                } icon: {
                    NCIcon(.email, label: .decorative)
                }
                .labelStyle(.nc)

                Label {
                    Text(verbatim: "Quarterly planning and archived correspondence")
                } icon: {
                    NCIcon(.folderOutline, label: .decorative)
                }
                .labelStyle(.nc)

                HStack(spacing: 8) {
                    Label {
                        Text(verbatim: "Archive")
                    } icon: {
                        NCIcon(.folderOutline, label: .decorative)
                    }
                    Label {
                        Text(verbatim: "Delete")
                    } icon: {
                        NCIcon(.deleteOutline, label: .decorative)
                    }
                }
                .labelStyle(.ncIconOnly)
            }
            .frame(width: 260, alignment: .leading),
            named: "layouts",
            height: 140
        )
    }

    // MARK: Progress style

    @Test("progress roles and bounds")
    func progressRoles() {
        assertInput(
            VStack(alignment: .leading, spacing: 12) {
                ProgressView(value: 0.62) { Text(verbatim: "offsite-photos.zip") }
                    .progressViewStyle(.normal)
                ProgressView(value: 0.4) { Text(verbatim: "Retrying") }
                    .progressViewStyle(.warning)
                ProgressView(value: 0.15) { Text(verbatim: "Upload failed") }
                    .progressViewStyle(.error)
                ProgressView(value: 0).progressViewStyle(.normal)
                ProgressView(value: 1).progressViewStyle(.normal)
            }
            .frame(width: 260),
            named: "roles",
            height: 200
        )
    }

    @Test("progress roles in dark")
    func progressRolesDark() {
        assertInput(
            VStack(alignment: .leading, spacing: 12) {
                ProgressView(value: 0.62).progressViewStyle(.normal)
                ProgressView(value: 0.62).progressViewStyle(.warning)
                ProgressView(value: 0.62).progressViewStyle(.error)
            }
            .frame(width: 260),
            named: "roles",
            height: 120,
            scheme: .dark
        )
    }

    // MARK: User picker

    private static let candidates = [
        NCUserCandidate(
            id: "lorelai", displayName: "Lorelai Taylor", secondary: "lorelai@example.com", status: .online),
        NCUserCandidate(id: "tom", displayName: "Tom Mörtel", secondary: "tom@example.com", status: .away),
        NCUserCandidate(id: "zaki", displayName: "Zaki Cortes", secondary: "zaki@example.com"),
        NCUserCandidate(id: "design", displayName: "Design team", secondary: "12 members"),
    ]

    /// A wrapper rather than a bare `NCUserPicker`, because the picker takes a
    /// binding and `.constant` would not survive the chips' remove buttons.
    private struct PickerHost: View {
        let candidates: [NCUserCandidate]
        @State var selection: Set<String>

        var body: some View {
            NCUserPicker(candidates: candidates, selection: $selection)
        }
    }

    @Test("picker with nothing selected")
    func pickerEmptySelection() {
        assertInput(
            PickerHost(candidates: Self.candidates, selection: []),
            named: "unselected",
            height: 300
        )
    }

    @Test("picker with a selection")
    func pickerWithSelection() {
        assertInput(
            PickerHost(candidates: Self.candidates, selection: ["lorelai", "tom"]),
            named: "selected",
            height: 300
        )
    }

    @Test("picker with a selection in dark")
    func pickerWithSelectionDark() {
        assertInput(
            PickerHost(candidates: Self.candidates, selection: ["lorelai", "tom"]),
            named: "selected",
            height: 300,
            scheme: .dark
        )
    }

    /// No candidates at all, which is the empty state the system writes.
    @Test("picker with no candidates")
    func pickerNoCandidates() {
        assertInput(
            PickerHost(candidates: [], selection: []),
            named: "noCandidates",
            height: 300
        )
    }

    @Test("picker long content truncates in the chip and the row")
    func pickerLongContent() {
        assertInput(
            PickerHost(
                candidates: [
                    NCUserCandidate(
                        id: "ellena",
                        displayName: "Ellena Wright Frederic Conway de la Vega-Kowalski",
                        secondary: "ellena.wright.frederic.conway@a-very-long-instance-name.example.com"
                    )
                ],
                selection: ["ellena"]
            ),
            named: "longContent",
            height: 300
        )
    }

    // MARK: Reaction picker

    private static let summary = NCReactionSummary([
        NCReaction(emoji: "👍", count: 4, isMine: true),
        NCReaction(emoji: "🎉", count: 2),
        NCReaction(emoji: "❤️", count: 1),
    ])

    @Test("reaction row")
    func reactionRow() {
        assertInput(
            NCReactionPicker(Self.summary) { _ in },
            named: "row",
            height: 60
        )
    }

    @Test("reaction row in dark")
    func reactionRowDark() {
        assertInput(
            NCReactionPicker(Self.summary) { _ in },
            named: "row",
            height: 60,
            scheme: .dark
        )
    }

    /// One pill fits and the rest fall into the menu, so the row keeps its width
    /// however many kinds of reaction a message collects.
    @Test("reaction row overflowing")
    func reactionOverflow() {
        assertInput(
            NCReactionPicker(Self.summary, visibleLimit: 1) { _ in },
            named: "overflow",
            height: 60
        )
    }

    @Test("reaction row with nothing on the message")
    func reactionEmpty() {
        assertInput(
            NCReactionPicker(NCReactionSummary([])) { _ in },
            named: "empty",
            height: 60
        )
    }

    @Test("reaction row with counts past a thousand")
    func reactionLongContent() {
        assertInput(
            NCReactionPicker(
                NCReactionSummary([
                    NCReaction(emoji: "👍", count: 1284, isMine: true),
                    NCReaction(emoji: "🎉", count: 942),
                    NCReaction(emoji: "❤️", count: 517),
                ])
            ) { _ in },
            named: "longContent",
            height: 60
        )
    }
}
