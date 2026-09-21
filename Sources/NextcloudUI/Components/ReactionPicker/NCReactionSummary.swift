// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

/// One emoji and how many people used it.
public nonisolated struct NCReaction: Identifiable, Hashable, Sendable {
    /// The emoji itself. Caller data: it is whatever the server stored.
    public let emoji: String
    /// How many people reacted with it, including this account.
    public let count: Int
    /// Whether this account is one of them.
    public let isMine: Bool

    public var id: String { emoji }

    public init(emoji: String, count: Int, isMine: Bool = false) {
        self.emoji = emoji
        self.count = count
        self.isMine = isMine
    }
}

/// Every reaction on one message, and what happens when this account adds or
/// removes one.
///
/// Talk's reaction row has three rules that are easy to get wrong and do not
/// need a view to test: removing the last reaction of a kind removes the pill
/// rather than leaving a zero, an emoji nobody has used yet appears with a count
/// of one, and the row does not reorder under the pointer.
///
/// ```swift
/// var summary = NCReactionSummary([
///     NCReaction(emoji: "👍", count: 3, isMine: true),
///     NCReaction(emoji: "🎉", count: 1),
/// ])
/// summary = summary.toggling("👍")   // 👍 drops to 2, no longer mine
/// ```
public nonisolated struct NCReactionSummary: Hashable, Sendable {

    /// The reactions, most-used first.
    public let reactions: [NCReaction]

    /// Creates a summary from what the server reported.
    ///
    /// Reactions with a count of zero or less are dropped, and a repeated emoji
    /// keeps only its first entry -- a server that sends the same emoji twice is
    /// reporting a bug, and showing two identical pills makes it the client's.
    ///
    /// The result is sorted by count, and ties keep the order they arrived in,
    /// so the row is the same on every client that talks to the same server.
    public init(_ reactions: [NCReaction]) {
        var seen: Set<String> = []
        let cleaned = reactions.filter { reaction in
            reaction.count > 0 && seen.insert(reaction.emoji).inserted
        }
        // Sorting on the arrival position rather than trusting a sort to be
        // stable: Swift does not promise stability, and a row whose order
        // changes between builds is a bug nobody reproduces.
        self.reactions =
            cleaned
            .enumerated()
            .sorted { lhs, rhs in
                lhs.element.count == rhs.element.count
                    ? lhs.offset < rhs.offset
                    : lhs.element.count > rhs.element.count
            }
            .map(\.element)
    }

    /// Everyone who reacted, counted once per reaction they left.
    public var total: Int { reactions.reduce(0) { $0 + $1.count } }

    /// The summary after this account taps `emoji`.
    ///
    /// Adding a new emoji appends it at the end rather than re-sorting, and
    /// changing a count leaves the pill where it is. Sorting on every tap would
    /// move the pill out from under the pointer mid-click, which reads as a
    /// misfire even when the toggle worked.
    public func toggling(_ emoji: String) -> NCReactionSummary {
        guard let index = reactions.firstIndex(where: { $0.emoji == emoji }) else {
            return NCReactionSummary(preserving: reactions + [NCReaction(emoji: emoji, count: 1, isMine: true)])
        }

        let existing = reactions[index]
        var updated = reactions
        if existing.isMine {
            if existing.count <= 1 {
                updated.remove(at: index)
            } else {
                updated[index] = NCReaction(emoji: emoji, count: existing.count - 1, isMine: false)
            }
        } else {
            updated[index] = NCReaction(emoji: emoji, count: existing.count + 1, isMine: true)
        }
        return NCReactionSummary(preserving: updated)
    }

    /// The reactions a row can show, and the ones the overflow menu holds.
    ///
    /// - Parameter limit: How many pills fit. Zero or less puts everything in
    ///   the overflow, which is what a very narrow row does.
    public func split(visible limit: Int) -> (visible: [NCReaction], overflow: [NCReaction]) {
        let kept = max(limit, 0)
        return (Array(reactions.prefix(kept)), Array(reactions.dropFirst(kept)))
    }

    /// Keeps the order it is given, which the public initialiser never does.
    private init(preserving reactions: [NCReaction]) {
        self.reactions = reactions
    }
}
