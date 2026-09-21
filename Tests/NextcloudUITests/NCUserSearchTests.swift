// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import Testing

@testable import NextcloudUI

@Suite("User search")
struct NCUserSearchTests {

    /// One contact list used by most of the tests, in the order a server would
    /// return it, so that "the pool's own order survives" means something
    /// checkable.
    private let pool = [
        NCUserCandidate(id: "lorelai", displayName: "Lorelai Taylor", secondary: "lorelai@example.com"),
        NCUserCandidate(id: "tom", displayName: "Tom Mörtel", secondary: "tom@example.com"),
        NCUserCandidate(id: "tomasz", displayName: "Tomasz Nowak", secondary: "tn@example.com"),
        NCUserCandidate(id: "zaki", displayName: "Zaki Cortes", secondary: "ztom@example.com"),
        NCUserCandidate(id: "design", displayName: "Design team", secondary: nil),
    ]

    private func ids(_ query: String, excluding excluded: Set<String> = []) -> [String] {
        NCUserSearch.matches(pool, query: query, excluding: excluded).map(\.id)
    }

    // MARK: Degenerate inputs

    /// An empty field means "no filter", not "no results". A picker that showed
    /// nothing until a letter was typed would hide the whole contact list.
    @Test("an empty query returns the whole pool in its own order")
    func emptyQuery() {
        #expect(ids("") == ["lorelai", "tom", "tomasz", "zaki", "design"])
    }

    @Test("a whitespace-only query is the same as an empty one", arguments: [" ", "   ", "\t", "\n "])
    func whitespaceQuery(query: String) {
        #expect(ids(query) == ids(""))
    }

    @Test("an empty pool returns nothing rather than crashing")
    func emptyPool() {
        #expect(NCUserSearch.matches([], query: "tom").isEmpty)
        #expect(NCUserSearch.matches([], query: "").isEmpty)
    }

    @Test("a query nobody matches returns nothing")
    func noMatches() {
        #expect(ids("qqq").isEmpty)
    }

    // MARK: Folding

    /// Typing "mortel" has to find "Mörtel". A German contact list is full of
    /// names nobody types with their diacritics.
    @Test("matching ignores diacritics")
    func diacritics() {
        #expect(ids("mortel") == ["tom"])
        #expect(ids("Mörtel") == ["tom"])
    }

    @Test("matching ignores case", arguments: ["lorelai", "LORELAI", "LoReLaI"])
    func caseInsensitive(query: String) {
        #expect(ids(query) == ["lorelai"])
    }

    /// A CJK keyboard produces full-width Latin letters. Without width folding
    /// they match nothing at all, which looks like a broken search field.
    @Test("matching ignores full-width forms")
    func fullWidth() {
        #expect(ids("ｔｏｍ") == ids("tom"))
    }

    @Test("surrounding whitespace in the query is ignored")
    func trimmedQuery() {
        #expect(ids("  tom  ") == ids("tom"))
    }

    // MARK: Ranking

    /// "tom" is a display-name prefix for two people, a secondary-field prefix
    /// for nobody, and merely contained in Zaki's address. The prefixes come
    /// first, in the pool's order, and the containment match comes last.
    @Test("display-name prefixes outrank containment")
    func prefixesFirst() {
        #expect(ids("tom") == ["tom", "tomasz", "zaki"])
    }

    /// Someone searching by address expects the address match first, even though
    /// "tn" appears nowhere in a display name.
    @Test("a secondary-field prefix ranks above a plain containment match")
    func secondaryPrefix() {
        let pool = [
            NCUserCandidate(id: "contains", displayName: "Martin Bailey", secondary: "mb@example.com"),
            NCUserCandidate(id: "prefix", displayName: "Tomasz Nowak", secondary: "tin@example.com"),
        ]
        #expect(NCUserSearch.matches(pool, query: "tin").map(\.id) == ["prefix", "contains"])
    }

    /// Nothing about the ranking may disturb the server's order inside a tier.
    /// A list that reshuffles as each letter is typed is unusable with a mouse.
    @Test("the pool's order survives inside a tier")
    func stableWithinTier() {
        let pool = (0..<20).map {
            NCUserCandidate(id: "\($0)", displayName: "Team \($0)", secondary: nil)
        }
        let result = NCUserSearch.matches(pool, query: "team").map(\.id)
        #expect(result == pool.map(\.id))
    }

    @Test("a candidate with no secondary field still matches on its name")
    func noSecondary() {
        #expect(ids("design") == ["design"])
    }

    // MARK: Exclusion

    /// A recipient already on the To: line must not be offered again.
    @Test("excluded ids are dropped")
    func exclusion() {
        #expect(ids("tom", excluding: ["tom"]) == ["tomasz", "zaki"])
    }

    @Test("exclusion applies to an empty query too")
    func exclusionWithEmptyQuery() {
        #expect(ids("", excluding: ["lorelai", "design"]) == ["tom", "tomasz", "zaki"])
    }

    @Test("excluding everything leaves nothing")
    func exclusionOfEverything() {
        #expect(ids("", excluding: Set(pool.map(\.id))).isEmpty)
    }

    /// An id that is not in the pool is not an error; a picker's selection can
    /// legitimately outlive the candidate list it came from.
    @Test("an unknown excluded id changes nothing")
    func unknownExclusion() {
        #expect(ids("tom", excluding: ["nobody"]) == ids("tom"))
    }
}
