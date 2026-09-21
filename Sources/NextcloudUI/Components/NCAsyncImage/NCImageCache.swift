// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// The identity of a cached image.
///
/// A failable initialiser rather than a plain `String`, because a blank identity
/// is the one input that quietly corrupts the cache: every unidentified image
/// would share a single entry, so one person's photo would appear beside another
/// person's name. Rejecting it here means ``NCAsyncImage`` skips the cache
/// instead of poisoning it.
public nonisolated struct NCImageCacheKey: Hashable, Sendable {
    public let identity: String

    /// Creates a key, or returns `nil` when the identity carries nothing to tell
    /// it apart by.
    public init?(identity: String) {
        guard identity.contains(where: { !$0.isWhitespace }) else { return nil }
        self.identity = identity
    }
}

/// Which entry an ``NCImageCache`` drops when it is full.
///
/// Least-recently-used, kept as a plain value type so the ordering rules are
/// testable without an actor, a clock or a real image.
public nonisolated struct NCImageCacheEviction: Hashable, Sendable {
    /// The most entries the cache holds.
    public let capacity: Int

    /// Keys in use order, least recently used first.
    public private(set) var keys: [NCImageCacheKey] = []

    /// - Parameter capacity: Negative values are clamped to zero.
    public init(capacity: Int) {
        self.capacity = max(capacity, 0)
    }

    /// Records a use and returns the key that must now be dropped, if any.
    ///
    /// A key used again moves to the newest position, which is the whole of the
    /// policy. At a capacity of zero the key just used comes straight back, so a
    /// cache built that way stores nothing.
    public mutating func use(_ key: NCImageCacheKey) -> NCImageCacheKey? {
        keys.removeAll { $0 == key }
        keys.append(key)
        guard keys.count > capacity else { return nil }
        return keys.removeFirst()
    }
}

/// A bounded in-memory image cache.
///
/// A message list scrolls the same twenty faces past the reader over and over,
/// and without this every pass calls the app's loader again. The bound matters
/// more than the hit rate: an unbounded dictionary of decoded avatars is a leak
/// that only shows up in a long session.
///
/// Nothing is written to disk. The app owns the URL cache and the credentials;
/// this holds decoded images and nothing else.
public actor NCImageCache {
    /// The cache ``NCAsyncImage`` uses unless a caller passes its own.
    public static let shared = NCImageCache()

    private var images: [NCImageCacheKey: Image] = [:]
    private var eviction: NCImageCacheEviction

    /// - Parameter capacity: The most images held at once. The default covers a
    ///   long scrollback of a message list. The exact number matters little:
    ///   any bound fixes the leak, and a decoded 64pt avatar is small.
    public init(capacity: Int = 128) {
        eviction = NCImageCacheEviction(capacity: capacity)
    }

    /// The cached image for a key, counting the hit as a use.
    public func image(for key: NCImageCacheKey) -> Image? {
        guard let image = images[key] else { return nil }
        _ = eviction.use(key)
        return image
    }

    /// Stores an image, dropping the least recently used entry if that puts the
    /// cache over capacity.
    public func store(_ image: Image, for key: NCImageCacheKey) {
        images[key] = image
        if let evicted = eviction.use(key) {
            images[evicted] = nil
        }
    }

    /// Empties the cache. Call this when the app signs out, so the next account
    /// does not inherit the previous one's faces.
    public func removeAll() {
        images.removeAll()
        eviction = NCImageCacheEviction(capacity: eviction.capacity)
    }
}
