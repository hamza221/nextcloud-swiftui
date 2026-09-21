# ``NCAsyncImage``

## Overview

The app fetches the bytes and decodes them; this view shows the result and holds
onto it. That split is not stylistic. The package carries no credentials and
opens no connections, and a Nextcloud avatar endpoint answers 401 to an
unauthenticated request, so a view that fetched for itself would be broken on
every private instance. SwiftUI's own loading view is rejected by a lint rule for
that reason.

```swift
NCAsyncImage(identity: user.id, label: .content(user.displayName)) {
    let data = try await client.get("/avatar/\(user.id)/64")
    guard let image = NCImageDecoder.image(from: data, maximumPixelSize: 128) else {
        throw AvatarError.undecodable
    }
    return image
} placeholder: {
    NCAvatar(displayName: user.displayName)
}
```

### Phases

A load is pending, loaded, or failed. Pending and failed both render the
placeholder, because the placeholder a caller supplies for an avatar -- initials
on a generated colour -- is already the right thing to show when the photo never
arrives. A caller who needs a retry button should say so; there is no failure
slot yet.

The load restarts whenever `identity` changes, which is what a list does when it
recycles a row onto a different person. The previous image is cleared first, so a
row never shows one person's face under another person's name.

### Caching

``NCImageCache`` is an actor holding decoded images with a bounded entry count
and a least-recently-used eviction policy. Nothing touches the disk: the app owns
the URL cache.

The identity is the cache key, and it must cover everything the loader varies by.
``NCAvatar`` appends the diameter for exactly this reason, so the same person at
20pt and at 64pt are two entries rather than one blurred one.

An identity with no non-whitespace character is loaded but never cached, because
one shared entry for every unidentified image is worse than no cache at all. That
rule lives in ``NCImageCacheKey``, whose initialiser is failable.

Pass a separate ``NCImageCache`` when one screen's images should not evict
another's, and call ``NCImageCache/removeAll()`` on sign-out.

## Topics

### Caching

- ``NCImageCache``
- ``NCImageCacheKey``
- ``NCImageCacheEviction``
