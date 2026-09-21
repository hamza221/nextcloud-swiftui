// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

#Preview("NoteCard / roles", traits: .ncTheme) {
    VStack(spacing: 12) {
        ForEach(NCNoteCard<Text>.Role.allCases, id: \.self) { role in
            NCNoteCard(role, title: "Shared folder", message: "Anyone with the link can edit.")
        }
    }
    .frame(width: 380)
    .padding()
}

#Preview("NoteCard / no title", traits: .ncTheme) {
    NCNoteCard(.info, message: "Your changes are saved automatically.")
        .frame(width: 380)
        .padding()
}

#Preview("NoteCard / long content", traits: .ncTheme) {
    NCNoteCard(.warning, title: "Storage almost full") {
        Text(verbatim: String(repeating: "This account is close to its quota. ", count: 6))
    }
    .frame(width: 380)
    .padding()
}

#Preview("NoteCard / dark", traits: .ncTheme) {
    VStack(spacing: 12) {
        ForEach(NCNoteCard<Text>.Role.allCases, id: \.self) { role in
            NCNoteCard(role, message: "Anyone with the link can edit.")
        }
    }
    .frame(width: 380)
    .padding()
    .preferredColorScheme(.dark)
}

#endif
