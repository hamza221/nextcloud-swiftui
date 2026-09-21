// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

#Preview("HighlightText / matches", traits: .ncTheme) {
    VStack(alignment: .leading, spacing: 8) {
        NCHighlightText("Lorelai Taylor", matching: "lor")
        NCHighlightText("Tom Mörtel", matching: "mortel")
        NCHighlightText("banana", matching: "an")
        // An empty query must highlight nothing, not everything.
        NCHighlightText("Nothing highlighted", matching: "")
    }
    .padding()
}

#Preview("HighlightText / dark", traits: .ncTheme) {
    NCHighlightText("Lorelai Taylor", matching: "lor")
        .padding()
        .preferredColorScheme(.dark)
}

#endif
