// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI
import Testing

@testable import NextcloudUI

@Suite("Image cache keys")
struct NCImageCacheKeyTests {
    /// The bug this prevents: with a blank key every unidentified image shares
    /// one entry, so one person's photo appears beside another person's name.
    @Test("refuses an identity with nothing to tell it apart by", arguments: ["", " ", "\n\t "])
    func blankIsRejected(_ identity: String) {
        #expect(NCImageCacheKey(identity: identity) == nil)
    }

    @Test("keeps the identity verbatim")
    func distinctIdentities() throws {
        let lorelai = try #require(NCImageCacheKey(identity: "lorelai"))
        let zaki = try #require(NCImageCacheKey(identity: "zaki"))
        #expect(lorelai.identity == "lorelai")
        #expect(lorelai != zaki)
        #expect(try lorelai == #require(NCImageCacheKey(identity: "lorelai")))
    }

    /// `NCAvatar` appends the diameter, so the same person at two sizes is two
    /// entries rather than one blurred one.
    @Test("treats a suffixed identity as a different image")
    func sizeSuffixed() throws {
        let small = try #require(NCImageCacheKey(identity: "lorelai@20"))
        let large = try #require(NCImageCacheKey(identity: "lorelai@64"))
        #expect(small != large)
    }
}

@Suite("Image cache eviction")
struct NCImageCacheEvictionTests {
    private func key(_ identity: String) throws -> NCImageCacheKey {
        try #require(NCImageCacheKey(identity: identity))
    }

    @Test("evicts nothing until it is over capacity")
    func underCapacity() throws {
        var eviction = NCImageCacheEviction(capacity: 2)
        #expect(eviction.use(try key("a")) == nil)
        #expect(eviction.use(try key("b")) == nil)
        #expect(eviction.keys.count == 2)
    }

    @Test("drops the least recently used entry")
    func dropsOldest() throws {
        var eviction = NCImageCacheEviction(capacity: 2)
        _ = eviction.use(try key("a"))
        _ = eviction.use(try key("b"))
        #expect(eviction.use(try key("c")) == (try key("a")))
        #expect(eviction.keys == [try key("b"), try key("c")])
    }

    @Test("a second use moves an entry back to the newest position")
    func useRefreshes() throws {
        var eviction = NCImageCacheEviction(capacity: 2)
        _ = eviction.use(try key("a"))
        _ = eviction.use(try key("b"))
        _ = eviction.use(try key("a"))
        // "b" is now the oldest, so it goes rather than "a".
        #expect(eviction.use(try key("c")) == (try key("b")))
    }

    @Test("using the same key twice does not grow the queue")
    func noDuplicates() throws {
        var eviction = NCImageCacheEviction(capacity: 4)
        _ = eviction.use(try key("a"))
        _ = eviction.use(try key("a"))
        #expect(eviction.keys == [try key("a")])
    }

    @Test("a capacity of zero stores nothing")
    func zeroCapacity() throws {
        var eviction = NCImageCacheEviction(capacity: 0)
        #expect(eviction.use(try key("a")) == (try key("a")))
        #expect(eviction.keys.isEmpty)
    }

    @Test("clamps a negative capacity instead of trapping")
    func negativeCapacity() {
        #expect(NCImageCacheEviction(capacity: -5).capacity == 0)
    }
}

@Suite("Image cache")
struct NCImageCacheTests {
    private func key(_ identity: String) throws -> NCImageCacheKey {
        try #require(NCImageCacheKey(identity: identity))
    }

    @Test("returns what it was given")
    func roundTrip() async throws {
        let cache = NCImageCache(capacity: 2)
        let lorelai = try key("lorelai")
        #expect(await cache.image(for: lorelai) == nil)
        await cache.store(Image(systemName: "person"), for: lorelai)
        #expect(await cache.image(for: lorelai) != nil)
    }

    @Test("forgets the least recently used image once it is full")
    func evicts() async throws {
        let cache = NCImageCache(capacity: 2)
        let (a, b, c) = (try key("a"), try key("b"), try key("c"))
        await cache.store(Image(systemName: "person"), for: a)
        await cache.store(Image(systemName: "person"), for: b)
        // Reading "a" makes "b" the oldest.
        _ = await cache.image(for: a)
        await cache.store(Image(systemName: "person"), for: c)
        #expect(await cache.image(for: b) == nil)
        #expect(await cache.image(for: a) != nil)
        #expect(await cache.image(for: c) != nil)
    }

    @Test("empties on sign-out so the next account inherits no faces")
    func removeAll() async throws {
        let cache = NCImageCache(capacity: 2)
        let lorelai = try key("lorelai")
        await cache.store(Image(systemName: "person"), for: lorelai)
        await cache.removeAll()
        #expect(await cache.image(for: lorelai) == nil)
    }
}
