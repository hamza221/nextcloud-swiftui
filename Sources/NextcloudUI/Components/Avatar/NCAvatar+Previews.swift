// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

#Preview("Avatar / sizes", traits: .ncTheme) {
    HStack(alignment: .bottom, spacing: 12) {
        ForEach(NCAvatar.Size.allCases, id: \.self) { size in
            NCAvatar(displayName: "Lorelai Taylor", user: "lorelai", size: size)
        }
    }
    .padding()
}

#Preview("Avatar / fallback chain", traits: .ncTheme) {
    // Photo, then initials, then the person icon. The middle case is the one
    // most Nextcloud accounts land in.
    HStack(spacing: 12) {
        NCAvatar(displayName: "Has a photo", size: .large) {
            Image(systemName: "photo.artframe")
        }
        NCAvatar(displayName: "Lorelai Taylor", size: .large)
        NCAvatar(displayName: "🎉", size: .large)
    }
    .padding()
}

#Preview("Avatar / names", traits: .ncTheme) {
    // Every one of these has broken an avatar implementation somewhere.
    let names = ["Lorelai Taylor", "Cher", "田中 太郎", "محمد علي", "🎉 party", "", "  "]
    VStack(alignment: .leading, spacing: 6) {
        ForEach(names, id: \.self) { name in
            HStack {
                NCAvatar(displayName: name)
                Text(verbatim: name.isEmpty ? "(empty)" : name).font(.caption)
            }
        }
    }
    .padding()
}

#Preview("Avatar / long content", traits: .ncTheme) {
    HStack(spacing: 12) {
        NCAvatar(
            displayName: "Ellena Wright Frederic Conway de la Vega-Kowalski",
            size: .small
        )
        NCAvatar(
            displayName: "Ellena Wright Frederic Conway de la Vega-Kowalski",
            size: .extraLarge
        )
    }
    .padding()
}

#Preview("Avatar / status", traits: .ncTheme) {
    HStack(spacing: 12) {
        ForEach(NCUserStatus.allCases, id: \.self) { status in
            NCAvatar(displayName: "Tom Mörtel", user: "tom", size: .large, status: status)
        }
    }
    .padding()
}

#Preview("Avatar / empty", traits: .ncTheme) {
    // No name, no id, no photo. It must still be a circle of the right size with
    // a spoken label rather than a crash or a blank gap.
    NCAvatar(displayName: "", size: .extraLarge).padding()
}

#Preview("Avatar / dark", traits: .ncTheme) {
    HStack(spacing: 12) {
        NCAvatar(displayName: "Lorelai Taylor", user: "lorelai", size: .large, status: .online)
        NCAvatar(displayName: "Zaki Cortes", user: "zaki", size: .large, status: .away)
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Avatar / increased contrast", traits: .ncIncreasedContrast) {
    // The initials colour is derived with NCContrast rather than fixed to white,
    // so a gold avatar reads black and a purple one reads white.
    VStack(spacing: 12) {
        ForEach(["admin", "lorelai", "zaki", "Tom Mörtel"], id: \.self) { user in
            NCAvatar(displayName: user, user: user, size: .large)
        }
    }
    .padding()
}

#Preview("Avatar / RTL", traits: .ncTheme) {
    // The status badge belongs on the trailing edge, so it moves to the left.
    HStack {
        NCAvatar(displayName: "محمد علي", user: "mohammed", size: .large, status: .online)
        Text(verbatim: "محمد علي")
    }
    .environment(\.layoutDirection, .rightToLeft)
    .padding()
}

#endif
