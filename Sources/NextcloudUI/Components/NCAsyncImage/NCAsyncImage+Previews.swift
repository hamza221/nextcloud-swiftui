// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

/// Stand-ins for an app's loader. There is no network here and never will be.
nonisolated enum NCAsyncImagePreviewLoader {
    struct Failure: Error {}

    /// Resolves after a visible pause, so the placeholder is actually seen.
    static func slow() async throws -> Image {
        try await Task.sleep(for: .seconds(2))
        return Image(systemName: "photo.artframe")
    }

    static func immediate() async throws -> Image {
        Image(systemName: "photo.artframe")
    }

    static func failing() async throws -> Image {
        throw Failure()
    }
}

#Preview("NCAsyncImage / default", traits: .ncTheme) {
    NCAsyncImage(
        identity: "preview.immediate",
        label: .text(LocalizedStringResource(nc: "Online")),
        load: NCAsyncImagePreviewLoader.immediate
    ) {
        Color.gray.opacity(0.3)
    }
    .frame(width: 96, height: 96)
    .padding()
}

#Preview("NCAsyncImage / loading", traits: .ncTheme) {
    NCAsyncImage(
        identity: "preview.slow",
        label: .decorative,
        load: NCAsyncImagePreviewLoader.slow
    ) {
        ProgressView()
    }
    .frame(width: 96, height: 96)
    .padding()
}

#Preview("NCAsyncImage / failure falls back to the placeholder", traits: .ncTheme) {
    NCAsyncImage(
        identity: "preview.failing",
        label: .decorative,
        load: NCAsyncImagePreviewLoader.failing
    ) {
        NCAvatar(displayName: "Lorelai Taylor", size: .extraLarge)
    }
    .padding()
}

#Preview("NCAsyncImage / empty identity skips the cache", traits: .ncTheme) {
    // An identity with nothing to tell it apart by must still load; it just must
    // not share a cache entry with every other unidentified image.
    NCAsyncImage(
        identity: "",
        label: .decorative,
        load: NCAsyncImagePreviewLoader.immediate
    ) {
        Color.gray.opacity(0.3)
    }
    .frame(width: 96, height: 96)
    .padding()
}

#Preview("NCAsyncImage / dark", traits: .ncTheme) {
    NCAsyncImage(
        identity: "preview.dark",
        label: .decorative,
        load: NCAsyncImagePreviewLoader.immediate
    ) {
        Color.gray.opacity(0.3)
    }
    .frame(width: 96, height: 96)
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("NCAsyncImage / RTL", traits: .ncTheme) {
    HStack {
        NCAsyncImage(
            identity: "preview.rtl",
            label: .decorative,
            load: NCAsyncImagePreviewLoader.immediate
        ) {
            Color.gray.opacity(0.3)
        }
        .frame(width: 48, height: 48)
        Text(verbatim: "مرحبا بالعالم")
    }
    .environment(\.layoutDirection, .rightToLeft)
    .padding()
}

#Preview("NCAsyncImage / increased contrast", traits: .ncIncreasedContrast) {
    // This view paints nothing of its own, so what there is to check is that the
    // caller's placeholder still separates from the background while loading.
    NCAsyncImage(
        identity: "preview.contrast",
        label: .decorative,
        load: NCAsyncImagePreviewLoader.immediate
    ) {
        Color.gray.opacity(0.3)
    }
    .frame(width: 96, height: 96)
    .padding()
}

#endif
