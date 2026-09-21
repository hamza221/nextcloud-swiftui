// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

internal import Foundation

/// One person offered by a picker.
///
/// All three text fields are caller data from the server, so none of them ever
/// goes through a localisation table.
public nonisolated struct NCUserCandidate: Identifiable, Hashable, Sendable {
    /// The account id, a federated cloud id, or a group id. Used as the
    /// selection value and as the avatar colour seed, so it must be stable
    /// across a display-name change.
    public let id: String
    /// The person's name, as the server reports it.
    public let displayName: String
    /// What tells two people with the same name apart: an e-mail address, a
    /// cloud id, a group name.
    public let secondary: String?
    /// Presence, when the instance reports it.
    public let status: NCUserStatus?

    public init(
        id: String,
        displayName: String,
        secondary: String? = nil,
        status: NCUserStatus? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.secondary = secondary
        self.status = status
    }
}

/// Which candidates a query matches, and in what order.
///
/// This is the part of ``NCUserPicker`` with edge cases, and none of them need
/// SwiftUI to exercise. A Nextcloud contact list is full of them: "Mörtel" has
/// to be found by typing "mortel", two colleagues share a display name and are
/// told apart by their address, and a recipient already on the To: line must
/// stop being offered.
///
/// Matching is on the *folded* form of both sides, so it is insensitive to case,
/// to diacritics, and to the full-width forms that a CJK keyboard produces.
public nonisolated enum NCUserSearch {

    /// The candidates a query matches, best first.
    ///
    /// - Parameters:
    ///   - candidates: The pool, in the order the server returned it.
    ///   - query: What the person typed. Empty or whitespace-only returns the
    ///     whole pool rather than nothing, because an empty field means "no
    ///     filter", not "no results".
    ///   - excluded: Ids to drop. A picker passes what is already selected, so
    ///     a recipient is not offered twice.
    /// - Returns: Display-name prefix matches, then secondary-field prefix
    ///   matches, then anything containing the query. Within a tier the pool's
    ///   own order survives, so a list does not reshuffle as a letter is typed.
    public static func matches(
        _ candidates: [NCUserCandidate],
        query: String,
        excluding excluded: Set<String> = []
    ) -> [NCUserCandidate] {
        let pool = excluded.isEmpty ? candidates : candidates.filter { !excluded.contains($0.id) }
        let needle = folded(query)
        guard !needle.isEmpty else { return pool }

        // Sorting on (tier, original index) rather than calling a sort that
        // happens to be stable: Swift does not promise stability, and an order
        // that changes between builds is the kind of bug nobody reproduces.
        return
            pool
            .enumerated()
            .compactMap { position, candidate -> (tier: Int, position: Int, candidate: NCUserCandidate)? in
                guard let tier = tier(of: candidate, matching: needle) else { return nil }
                return (tier, position, candidate)
            }
            .sorted { ($0.tier, $0.position) < ($1.tier, $1.position) }
            .map(\.candidate)
    }

    /// How well a candidate matches, or `nil` for no match at all.
    ///
    /// An exact prefix of the display name wins, because that is what someone
    /// typing a name expects to see first. A prefix of the secondary field comes
    /// next, which is how an address-first search behaves. Everything else that
    /// merely contains the query is last.
    private static func tier(of candidate: NCUserCandidate, matching needle: String) -> Int? {
        let name = folded(candidate.displayName)
        let secondary = candidate.secondary.map(folded) ?? ""
        if name.hasPrefix(needle) { return 0 }
        if secondary.hasPrefix(needle) { return 1 }
        if name.contains(needle) || secondary.contains(needle) { return 2 }
        return nil
    }

    /// The comparison form of a string.
    ///
    /// A fixed `nil` locale rather than the current one, so that a Turkish
    /// build does not fold a dotted capital I differently from a German build
    /// and give two users different search results from the same contact list.
    private static func folded(_ value: String) -> String {
        value
            .folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
