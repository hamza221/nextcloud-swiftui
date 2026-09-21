// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

    import SwiftUI

    #Preview("CounterBubble / roles", traits: .ncTheme) {
        HStack(spacing: 12) {
            ForEach(NCCounterBubble.Role.allCases, id: \.self) { role in
                NCCounterBubble(count: 7, role: role)
            }
        }
        .padding()
    }

    #Preview("CounterBubble / magnitudes", traits: .ncTheme) {
        HStack(spacing: 12) {
            // Zero renders nothing at all, which is the point of the first slot
            // looking empty.
            ForEach([0, 1, 42, 99, 100, 12_345], id: \.self) { count in
                NCCounterBubble(count: count, role: .highlighted)
            }
        }
        .padding()
    }

    #Preview("CounterBubble / dark", traits: .ncTheme) {
        HStack(spacing: 12) {
            ForEach(NCCounterBubble.Role.allCases, id: \.self) { role in
                NCCounterBubble(count: 7, role: role)
            }
        }
        .padding()
        .preferredColorScheme(.dark)
    }

#endif
