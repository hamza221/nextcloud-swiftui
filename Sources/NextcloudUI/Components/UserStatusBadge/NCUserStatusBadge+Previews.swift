// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

#Preview("UserStatusBadge / all statuses", traits: .ncTheme) {
    // Each status must be distinguishable by shape alone, not only by
    // colour: view this preview in greyscale before changing it.
    HStack(spacing: 16) {
        ForEach(NCUserStatus.allCases, id: \.self) { status in
            VStack {
                NCUserStatusBadge(status)
                Text(status.accessibilityLabel).font(.caption2)
            }
        }
    }
    .padding()
}

#Preview("UserStatusBadge / dark", traits: .ncTheme) {
    HStack(spacing: 16) {
        ForEach(NCUserStatus.allCases, id: \.self) { status in
            NCUserStatusBadge(status)
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("UserStatusBadge / increased contrast", traits: .ncIncreasedContrast) {
    // Shape carries the meaning here and colour only reinforces it, so this
    // preview should look almost identical to the first one.
    HStack(spacing: 16) {
        ForEach(NCUserStatus.allCases, id: \.self) { status in
            NCUserStatusBadge(status)
        }
    }
    .padding()
}

#endif
