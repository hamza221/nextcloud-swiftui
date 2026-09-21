// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import Testing

@testable import NextcloudUI

@Suite("Reaction summary")
struct NCReactionSummaryTests {

    private func summary(_ reactions: [NCReaction]) -> NCReactionSummary {
        NCReactionSummary(reactions)
    }

    private func emoji(_ summary: NCReactionSummary) -> [String] {
        summary.reactions.map(\.emoji)
    }

    // MARK: Normalising what the server sent

    @Test("an empty message has no reactions and no total")
    func empty() {
        let result = summary([])
        #expect(result.reactions.isEmpty)
        #expect(result.total == 0)
    }

    /// A count of zero is a reaction that was taken away. Drawing it leaves a
    /// pill reading "👍 0", which looks like a bug in the client rather than in
    /// the payload.
    @Test("non-positive counts are dropped", arguments: [0, -1, -100])
    func nonPositiveCounts(count: Int) {
        let result = summary([NCReaction(emoji: "👍", count: count)])
        #expect(result.reactions.isEmpty)
    }

    @Test("a repeated emoji keeps only its first entry")
    func duplicates() {
        let result = summary([
            NCReaction(emoji: "👍", count: 3, isMine: true),
            NCReaction(emoji: "👍", count: 9),
        ])
        #expect(result.reactions == [NCReaction(emoji: "👍", count: 3, isMine: true)])
    }

    @Test("reactions sort by count, most used first")
    func sortedByCount() {
        let result = summary([
            NCReaction(emoji: "❤️", count: 1),
            NCReaction(emoji: "👍", count: 7),
            NCReaction(emoji: "🎉", count: 3),
        ])
        #expect(emoji(result) == ["👍", "🎉", "❤️"])
    }

    /// Ties keep the order the server sent, so two clients talking to the same
    /// server draw the same row.
    @Test("ties keep the order they arrived in")
    func stableTies() {
        let result = summary([
            NCReaction(emoji: "🎉", count: 2),
            NCReaction(emoji: "❤️", count: 2),
            NCReaction(emoji: "👍", count: 2),
        ])
        #expect(emoji(result) == ["🎉", "❤️", "👍"])
    }

    @Test("the total counts every reaction")
    func total() {
        let result = summary([
            NCReaction(emoji: "👍", count: 7, isMine: true),
            NCReaction(emoji: "🎉", count: 3),
        ])
        #expect(result.total == 10)
    }

    // MARK: Toggling

    @Test("an emoji nobody has used appears with a count of one, as mine")
    func addNew() {
        let result = summary([]).toggling("🚀")
        #expect(result.reactions == [NCReaction(emoji: "🚀", count: 1, isMine: true)])
    }

    @Test("reacting to something others already used adds me to it")
    func joinExisting() {
        let result = summary([NCReaction(emoji: "👍", count: 3)]).toggling("👍")
        #expect(result.reactions == [NCReaction(emoji: "👍", count: 4, isMine: true)])
    }

    @Test("taking mine back leaves the others")
    func leaveExisting() {
        let result = summary([NCReaction(emoji: "👍", count: 3, isMine: true)]).toggling("👍")
        #expect(result.reactions == [NCReaction(emoji: "👍", count: 2, isMine: false)])
    }

    /// The pill goes, rather than staying at zero.
    @Test("taking back the only reaction removes the pill")
    func removeLast() {
        let result = summary([NCReaction(emoji: "👍", count: 1, isMine: true)]).toggling("👍")
        #expect(result.reactions.isEmpty)
    }

    @Test("toggling twice is a round trip")
    func roundTrip() {
        let start = summary([NCReaction(emoji: "👍", count: 3), NCReaction(emoji: "🎉", count: 1)])
        #expect(start.toggling("👍").toggling("👍") == start)
    }

    @Test("toggling an emoji leaves the others alone")
    func othersUntouched() {
        let result = summary([
            NCReaction(emoji: "👍", count: 3),
            NCReaction(emoji: "🎉", count: 1, isMine: true),
        ])
        .toggling("👍")
        #expect(result.reactions.last == NCReaction(emoji: "🎉", count: 1, isMine: true))
    }

    /// Re-sorting on each tap would slide the pill out from under the pointer
    /// mid-click, which reads as a misfire even when the toggle worked.
    @Test("toggling does not reorder the row")
    func orderSurvivesAToggle() {
        let start = summary([
            NCReaction(emoji: "👍", count: 3),
            NCReaction(emoji: "🎉", count: 2),
        ])
        #expect(emoji(start.toggling("🎉")) == ["👍", "🎉"])
    }

    @Test("a new emoji lands at the end rather than at its sorted position")
    func newReactionAppends() {
        let start = summary([NCReaction(emoji: "👍", count: 9)])
        #expect(emoji(start.toggling("🚀")) == ["👍", "🚀"])
    }

    // MARK: Splitting for the row

    private var three: NCReactionSummary {
        summary([
            NCReaction(emoji: "👍", count: 3),
            NCReaction(emoji: "🎉", count: 2),
            NCReaction(emoji: "❤️", count: 1),
        ])
    }

    @Test("a limit above the count puts everything in the row")
    func splitFits() {
        let split = three.split(visible: 10)
        #expect(split.visible.count == 3)
        #expect(split.overflow.isEmpty)
    }

    @Test("a limit below the count moves the rest into the overflow")
    func splitOverflows() {
        let split = three.split(visible: 2)
        #expect(split.visible.map(\.emoji) == ["👍", "🎉"])
        #expect(split.overflow.map(\.emoji) == ["❤️"])
    }

    /// A row too narrow for even one pill still has to render, with the whole
    /// set behind the menu.
    @Test("a limit of zero or less puts everything in the overflow", arguments: [0, -1])
    func splitNothingVisible(limit: Int) {
        let split = three.split(visible: limit)
        #expect(split.visible.isEmpty)
        #expect(split.overflow.count == 3)
    }

    @Test("splitting an empty summary gives two empty halves")
    func splitEmpty() {
        let split = summary([]).split(visible: 6)
        #expect(split.visible.isEmpty)
        #expect(split.overflow.isEmpty)
    }
}
