// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
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

    #Preview("UserStatusBadge / increased contrast", traits: .ncTheme) {
        HStack(spacing: 16) {
            ForEach(NCUserStatus.allCases, id: \.self) { status in
                NCUserStatusBadge(status)
            }
        }
        .padding()
        .environment(\.colorSchemeContrast, .increased)
    }

#endif
