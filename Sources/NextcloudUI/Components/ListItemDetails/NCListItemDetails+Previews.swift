// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

private let ages: [TimeInterval] = [30, 600, 7200, 200_000, 4_000_000]

#Preview("ListItemDetails / ages", traits: .ncTheme) {
    HStack(spacing: 20) {
        ForEach(ages, id: \.self) { age in
            NCListItemDetails(date: .now.addingTimeInterval(-age), unreadCount: 3)
        }
    }
    .padding()
}

#Preview("ListItemDetails / long content", traits: .ncTheme) {
    // The widest the cluster ever gets: a long relative string over a capped
    // count. Anything wider than this is a bug in the formatter, not in layout.
    HStack(spacing: 20) {
        NCListItemDetails(
            date: .now.addingTimeInterval(-4_000_000),
            unreadCount: 99_999,
            formatter: NCRelativeDateFormatter(width: .long)
        )
    }
    .padding()
}

#Preview("ListItemDetails / empty", traits: .ncTheme) {
    // Every partial combination, ending with nothing at all. The last cell draws
    // zero-sized, which is what keeps a read conversation from leaving a gap.
    HStack(spacing: 20) {
        NCListItemDetails(date: .now, unreadCount: 3)
        NCListItemDetails(date: .now)
        NCListItemDetails(unreadCount: 3)
        NCListItemDetails()
    }
    .padding()
    .border(.quaternary)
}

#Preview("ListItemDetails / dark", traits: .ncTheme) {
    HStack(spacing: 20) {
        ForEach(ages, id: \.self) { age in
            NCListItemDetails(date: .now.addingTimeInterval(-age), unreadCount: 3)
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("ListItemDetails / increased contrast", traits: .ncIncreasedContrast) {
    // The timestamp is `.secondary`, which the system darkens. If it ever stops
    // being legible here, the fix is a system style, not a token.
    HStack(spacing: 20) {
        ForEach(ages, id: \.self) { age in
            NCListItemDetails(date: .now.addingTimeInterval(-age), unreadCount: 3)
        }
    }
    .padding()
}

#Preview("ListItemDetails / RTL", traits: .ncTheme) {
    // The cluster aligns trailing, so it must mirror to the left-hand edge.
    NCListItemDetails(date: .now.addingTimeInterval(-7200), unreadCount: 12)
        .frame(width: 160, alignment: .trailing)
        .padding()
        .border(.quaternary)
        .environment(\.layoutDirection, .rightToLeft)
}

#endif
