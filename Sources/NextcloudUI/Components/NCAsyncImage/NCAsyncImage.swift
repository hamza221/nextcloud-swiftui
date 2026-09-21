// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// An image the app loads, with caller-supplied content shown until it arrives.
///
/// The loader closure is the whole design. This package has no credentials and
/// does no networking, and a Nextcloud avatar endpoint answers 401 without the
/// app's authenticated session -- so the app hands over
/// `@Sendable () async throws -> Image` and keeps its session to itself. The
/// stock SwiftUI loading view is banned by a lint rule for the same reason.
///
/// ```swift
/// NCAsyncImage(identity: user.id, label: .content(user.displayName)) {
///     try await client.avatar(for: user.id)   // returns an Image
/// } placeholder: {
///     Color.gray
/// }
/// ```
///
/// The app decodes with ``NCImageDecoder``, which downsamples straight to the
/// target size rather than holding a 2000px bitmap on its way to a 32pt avatar.
public struct NCAsyncImage<Placeholder: View>: View {
    private let identity: String
    private let label: NCAccessibilityLabel
    private let cache: NCImageCache
    private let load: @Sendable () async throws -> Image
    private let placeholder: Placeholder

    @State private var phase: Phase = .placeholder

    /// Where the load has got to.
    ///
    /// ponytail: a failed load renders the placeholder, same as a pending one.
    /// There is no separate failure slot and no retry, because the only caller
    /// in the library is ``NCAvatar``, whose placeholder -- initials on a
    /// generated colour -- is already the right thing to show when the photo
    /// never arrives. Add a `failure:` slot the first time a caller needs a
    /// retry button.
    private enum Phase {
        case placeholder
        case loaded(Image)
        case failed
    }

    /// Creates an image view.
    ///
    /// - Parameters:
    ///   - identity: What makes this image distinct, usually a user id or a file
    ///     id. It keys the cache and restarts the load when it changes. Include
    ///     anything the loader varies by, such as a pixel size. A blank identity
    ///     is loaded but not cached.
    ///   - label: How the image describes itself. ``NCAccessibilityLabel/decorative``
    ///     when an enclosing view already carries the meaning.
    ///   - cache: Defaults to ``NCImageCache/shared``. Pass a separate instance
    ///     to keep one screen's images from evicting another's.
    ///   - load: Fetches and decodes the image. Called on a task that is
    ///     cancelled when the view goes away.
    ///   - placeholder: Shown until the image arrives, and after a failure.
    public init(
        identity: String,
        label: NCAccessibilityLabel,
        cache: NCImageCache = .shared,
        load: @escaping @Sendable () async throws -> Image,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.identity = identity
        self.label = label
        self.cache = cache
        self.load = load
        self.placeholder = placeholder()
    }

    public var body: some View {
        content
            // The identity restarts the load when the view is recycled onto a
            // different person, which is exactly what a scrolling list does.
            .task(id: identity) { await resolve() }
            .accessibilityElement(children: .ignore)
            .ncAccessibilityLabel(label)
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .loaded(let image):
            image.resizable().scaledToFill()
        case .placeholder, .failed:
            placeholder
        }
    }

    private func resolve() async {
        let key = NCImageCacheKey(identity: identity)
        if let key, let cached = await cache.image(for: key) {
            phase = .loaded(cached)
            return
        }
        // A recycled view must not keep showing the previous person while the
        // new one loads.
        phase = .placeholder
        do {
            let image = try await load()
            if let key { await cache.store(image, for: key) }
            phase = .loaded(image)
        } catch {
            phase = .failed
        }
    }
}

extension NCAsyncImage where Placeholder == Color {
    /// Creates an image view whose placeholder is a plain fill.
    ///
    /// A constrained convenience initialiser, so the common call site never has
    /// to write a placeholder slot by hand.
    public init(
        identity: String,
        label: NCAccessibilityLabel,
        cache: NCImageCache = .shared,
        load: @escaping @Sendable () async throws -> Image
    ) {
        self.init(identity: identity, label: label, cache: cache, load: load) {
            Color.clear
        }
    }
}
