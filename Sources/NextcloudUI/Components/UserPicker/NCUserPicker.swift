// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// Pick one person, or several: a Mail recipient field, a Talk participant
/// list, a share sheet.
///
/// ```swift
/// NCUserPicker(candidates: contacts, selection: $recipients) { candidate in
///     try await client.avatar(for: candidate.id)
/// }
/// ```
///
/// ## Selection belongs to `List`
///
/// The candidate list is a `List(selection:)`, so arrow keys, type-select,
/// `⌘`-click, `⇧`-click ranges, the focus ring and the brand-tinted highlight
/// all arrive already built and already accessible. This view adds no key
/// handler of its own. A hand-rolled `onTapGesture` row would be a worse copy
/// that a keyboard cannot reach.
///
/// ## A selected person leaves the list
///
/// Picking someone moves them from the list into an ``NCChip`` above it, and
/// they stop being offered. That is what a recipient field does, and it is why
/// ``NCUserSearch/matches(_:query:excluding:)`` takes an exclusion set. Removal
/// is on the chip, where VoiceOver reaches it as a rotor action.
///
/// ## Filtering is not in here
///
/// Substring matching, folding and ranking live in ``NCUserSearch``, which has
/// no SwiftUI in it and is where the edge cases are tested. What is left in
/// `body` is composition.
public struct NCUserPicker: View {
    private let candidates: [NCUserCandidate]
    private let selection: Selection
    private let load: (@Sendable (NCUserCandidate) async throws -> Image)?

    @State private var query = ""
    @Environment(\.ncTheme) private var theme

    /// Which shape of `List` selection is in play.
    ///
    /// Two bindings rather than a `Bool`, because single and multiple selection
    /// are two different `List` initialisers. Faking one with the other loses
    /// `⌘`-click on the multiple side and allows an impossible second selection
    /// on the single side.
    private enum Selection {
        case one(Binding<String?>)
        case many(Binding<Set<String>>)
    }

    /// Creates a picker that takes several people.
    ///
    /// - Parameters:
    ///   - candidates: Everyone who may be picked, in the order the server
    ///     returned them. Caller data throughout.
    ///   - selection: The picked ids.
    ///   - load: Fetches a candidate's photo. Omit it and every row shows
    ///     initials on the person's own colour, which is what most Nextcloud
    ///     accounts have anyway.
    public init(
        candidates: [NCUserCandidate],
        selection: Binding<Set<String>>,
        load: (@Sendable (NCUserCandidate) async throws -> Image)? = nil
    ) {
        self.candidates = candidates
        self.selection = .many(selection)
        self.load = load
    }

    /// Creates a picker that takes one person.
    public init(
        candidates: [NCUserCandidate],
        selection: Binding<String?>,
        load: (@Sendable (NCUserCandidate) async throws -> Image)? = nil
    ) {
        self.candidates = candidates
        self.selection = .one(selection)
        self.load = load
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.spacing.standard) {
            selectedChips
            searchField
            candidateList
        }
    }

    // MARK: Selected

    private var selectedIDs: Set<String> {
        switch selection {
        case .one(let binding): binding.wrappedValue.map { [$0] } ?? []
        case .many(let binding): binding.wrappedValue
        }
    }

    /// The picked people in the pool's own order, so a chip does not jump when
    /// another is added.
    private var selectedCandidates: [NCUserCandidate] {
        let picked = selectedIDs
        return candidates.filter { picked.contains($0.id) }
    }

    private func deselect(_ id: String) {
        switch selection {
        case .one(let binding):
            if binding.wrappedValue == id { binding.wrappedValue = nil }
        case .many(let binding):
            binding.wrappedValue.remove(id)
        }
    }

    @ViewBuilder
    private var selectedChips: some View {
        if !selectedCandidates.isEmpty {
            // ponytail: one scrolling line rather than a wrapping flow. A
            // wrapping layout needs a custom `Layout`, and a recipient field
            // that scrolls is what Mail.app does. Revisit when a screen needs
            // twenty recipients visible at once.
            ScrollView(.horizontal) {
                HStack(spacing: theme.metrics.spacing.tight) {
                    ForEach(selectedCandidates) { candidate in
                        NCChip(
                            candidate.displayName,
                            role: .primary,
                            onRemove: { deselect(candidate.id) }
                        ) {
                            avatar(for: candidate, size: .small)
                        }
                    }
                }
            }
            .scrollIndicators(.never)
        }
    }

    // MARK: Search

    private var searchField: some View {
        TextField(
            text: $query,
            prompt: Text(LocalizedStringResource(nc: "Search people"))
        ) {
            Text(LocalizedStringResource(nc: "Search people"))
        }
        .textFieldStyle(.roundedBorder)
        // Hidden visually, kept for VoiceOver: the prompt disappears as soon as
        // a letter is typed, and a field with no name is a field nobody can
        // identify halfway through filling it in.
        .labelsHidden()
    }

    // MARK: Candidates

    private var matches: [NCUserCandidate] {
        NCUserSearch.matches(candidates, query: query, excluding: selectedIDs)
    }

    @ViewBuilder
    private var candidateList: some View {
        let filtered = matches
        if filtered.isEmpty {
            // The system already writes and translates "No Results for …" and
            // draws it at the right weight. An empty query lands here too, with
            // the generic wording, which is correct when a picker is handed an
            // empty contact list.
            ContentUnavailableView.search(text: query)
        } else {
            switch selection {
            case .one(let binding):
                List(filtered, selection: binding) { row($0) }
            case .many(let binding):
                List(filtered, selection: binding) { row($0) }
            }
        }
    }

    private func row(_ candidate: NCUserCandidate) -> some View {
        NCListItem(candidate.displayName, subtitle: candidate.secondary) {
            avatar(for: candidate, size: .medium)
        }
    }

    private func avatar(for candidate: NCUserCandidate, size: NCAvatar.Size) -> some View {
        NCAvatar(
            displayName: candidate.displayName,
            user: candidate.id,
            size: size,
            status: candidate.status,
            // The name is beside it in text, and hearing it twice is how a
            // recipient list becomes unbearable on VoiceOver.
            label: .decorative,
            load: loader(for: candidate)
        )
    }

    private func loader(for candidate: NCUserCandidate) -> (@Sendable () async throws -> Image)? {
        guard let load else { return nil }
        return { try await load(candidate) }
    }
}
