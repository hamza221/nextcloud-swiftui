// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

/// A preview host, so that tapping a pill actually changes the row: the picker
/// holds no state of its own and the caller owns the summary.
private struct NCReactionPickerHost: View {
    @State var summary: NCReactionSummary
    var visibleLimit = 6

    var body: some View {
        NCReactionPicker(summary, visibleLimit: visibleLimit) { emoji in
            summary = summary.toggling(emoji)
        }
        .padding()
    }
}

private let previewSummary = NCReactionSummary([
    NCReaction(emoji: "👍", count: 4, isMine: true),
    NCReaction(emoji: "🎉", count: 2),
    NCReaction(emoji: "❤️", count: 1),
])

#Preview("ReactionPicker / default", traits: .ncTheme) {
    NCReactionPickerHost(summary: previewSummary)
}

#Preview("ReactionPicker / overflow", traits: .ncTheme) {
    // Two pills fit; the rest move into the menu, still in count order.
    NCReactionPickerHost(summary: previewSummary, visibleLimit: 2)
}

#Preview("ReactionPicker / long content", traits: .ncTheme) {
    // Eight kinds of reaction on one message, with counts past a thousand. The
    // row shows six and the menu holds the rest.
    NCReactionPickerHost(
        summary: NCReactionSummary([
            NCReaction(emoji: "👍", count: 1284, isMine: true),
            NCReaction(emoji: "🎉", count: 942),
            NCReaction(emoji: "❤️", count: 517),
            NCReaction(emoji: "😀", count: 310),
            NCReaction(emoji: "🚀", count: 208),
            NCReaction(emoji: "👎", count: 97),
            NCReaction(emoji: "🤯", count: 42),
            NCReaction(emoji: "🇩🇪", count: 7),
        ])
    )
}

#Preview("ReactionPicker / empty", traits: .ncTheme) {
    // No reactions yet: the add button is the whole affordance.
    NCReactionPickerHost(summary: NCReactionSummary([]))
}

#Preview("ReactionPicker / dark", traits: .ncTheme) {
    NCReactionPickerHost(summary: previewSummary)
        .preferredColorScheme(.dark)
}

#Preview("ReactionPicker / increased contrast", traits: .ncIncreasedContrast) {
    // Watch whether a pill this account reacted with still reads as different
    // from one it did not. That difference is the chip's surface token.
    NCReactionPickerHost(summary: previewSummary)
}

#Preview("ReactionPicker / RTL", traits: .ncTheme) {
    // Counts use the locale's digits, so an Arabic build reads ٤ rather than 4.
    NCReactionPickerHost(summary: previewSummary)
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}

#Preview("ReactionPicker / under a message", traits: .ncTheme) {
    // Where the row actually lives.
    VStack(alignment: .leading, spacing: 4) {
        NCUserBubble(displayName: "Lorelai Taylor", user: "lorelai")
        Text(verbatim: "Deployment window moved to Thursday, same time.")
        NCReactionPickerHost(summary: previewSummary)
    }
    .frame(width: 320, alignment: .leading)
    .padding()
}

#endif
