// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

#Preview("KeyboardShortcutLabel / combinations", traits: .ncTheme) {
    VStack(alignment: .leading, spacing: 8) {
        NCKeyboardShortcutLabel(NCKeyboardShortcut("k", modifiers: [.command, .shift]))
        NCKeyboardShortcutLabel(NCKeyboardShortcut("n"))
        NCKeyboardShortcutLabel(NCKeyboardShortcut(.return, modifiers: [.command]))
        NCKeyboardShortcutLabel(NCKeyboardShortcut(.delete, modifiers: [.command, .option]))
        NCKeyboardShortcutLabel(
            NCKeyboardShortcut("f", modifiers: [.control, .option, .shift, .command])
        )
    }
    .padding()
}

#endif
