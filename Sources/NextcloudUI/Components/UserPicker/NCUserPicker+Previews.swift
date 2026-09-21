// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

/// A preview host, because the picker takes a binding and a preview body is not
/// a view with state.
private struct NCUserPickerHost: View {
    let candidates: [NCUserCandidate]
    var initial: Set<String> = []

    @State private var selection: Set<String> = []

    var body: some View {
        NCUserPicker(candidates: candidates, selection: $selection)
            .frame(width: 320, height: 320)
            .padding()
            .onAppear { selection = initial }
    }
}

private let previewCandidates: [NCUserCandidate] = [
    NCUserCandidate(id: "lorelai", displayName: "Lorelai Taylor", secondary: "lorelai@example.com", status: .online),
    NCUserCandidate(id: "tom", displayName: "Tom Mörtel", secondary: "tom@example.com", status: .away),
    NCUserCandidate(id: "zaki", displayName: "Zaki Cortes", secondary: "zaki@example.com", status: .doNotDisturb),
    NCUserCandidate(id: "ellena", displayName: "Ellena Wright", secondary: "ellena@example.com"),
    NCUserCandidate(id: "design", displayName: "Design team", secondary: "12 members"),
]

#Preview("UserPicker / default", traits: .ncTheme) {
    NCUserPickerHost(candidates: previewCandidates)
}

#Preview("UserPicker / with a selection", traits: .ncTheme) {
    // The picked people are chips above the field and are gone from the list
    // below it, which is what a recipient field does.
    NCUserPickerHost(candidates: previewCandidates, initial: ["lorelai", "tom"])
}

#Preview("UserPicker / single selection", traits: .ncTheme) {
    NCUserPickerSingleHost(candidates: previewCandidates)
}

private struct NCUserPickerSingleHost: View {
    let candidates: [NCUserCandidate]

    @State private var selection: String?

    var body: some View {
        NCUserPicker(candidates: candidates, selection: $selection)
            .frame(width: 320, height: 320)
            .padding()
    }
}

#Preview("UserPicker / long content", traits: .ncTheme) {
    NCUserPickerHost(
        candidates: [
            NCUserCandidate(
                id: "ellena",
                displayName: "Ellena Wright Frederic Conway de la Vega-Kowalski",
                secondary: "ellena.wright.frederic.conway@a-very-long-instance-name.example.com"
            ),
            NCUserCandidate(
                id: "planning",
                displayName: "Quarterly planning, archived correspondence and everything else",
                secondary: "384 members across four federated instances"
            ),
        ],
        initial: ["ellena"]
    )
}

#Preview("UserPicker / empty", traits: .ncTheme) {
    // No candidates at all. `ContentUnavailableView.search` writes and
    // translates the message; nothing here does.
    NCUserPickerHost(candidates: [])
}

#Preview("UserPicker / dark", traits: .ncTheme) {
    NCUserPickerHost(candidates: previewCandidates, initial: ["zaki"])
        .preferredColorScheme(.dark)
}

#Preview("UserPicker / increased contrast", traits: .ncTheme) {
    // `\.colorSchemeContrast` is read-only, so Increase Contrast cannot be
    // forced from preview code -- toggle it in the canvas accessibility
    // controls. Watch the chip's tinted surface and the secondary line in each
    // row, which are the two things that lose contrast first.
    NCUserPickerHost(candidates: previewCandidates, initial: ["lorelai"])
}

#Preview("UserPicker / RTL", traits: .ncTheme) {
    NCUserPickerHost(
        candidates: [
            NCUserCandidate(
                id: "mohammed", displayName: "محمد علي", secondary: "mohammed@example.com", status: .online),
            NCUserCandidate(id: "fatima", displayName: "فاطمة الزهراء", secondary: "fatima@example.com"),
        ],
        initial: ["mohammed"]
    )
    .environment(\.layoutDirection, .rightToLeft)
}

#endif
