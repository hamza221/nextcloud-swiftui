// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

#Preview("UserBubble / default", traits: .ncTheme) {
    VStack(alignment: .leading, spacing: 8) {
        NCUserBubble(displayName: "Lorelai Taylor", user: "lorelai")
        NCUserBubble(displayName: "Zaki Cortes", user: "zaki", status: .online)
        NCUserBubble(displayName: "Tom Mörtel", user: "tom", action: {})
    }
    .padding()
}

#Preview("UserBubble / trailing content", traits: .ncTheme) {
    NCUserBubble(displayName: "Lorelai Taylor", user: "lorelai", action: {}) {
        NCIcon(.close, label: .decorative, size: .small)
    }
    .padding()
}

#Preview("UserBubble / long content", traits: .ncTheme) {
    NCUserBubble(
        displayName: "ellena.wright.frederic.conway@a-very-long-instance-name.example.com",
        user: "ellena"
    )
    .frame(width: 260)
    .padding()
}

#Preview("UserBubble / empty", traits: .ncTheme) {
    // No name at all: still a bubble, not a collapsed sliver.
    NCUserBubble(displayName: "").padding()
}

#Preview("UserBubble / in a sentence", traits: .ncTheme) {
    // The mention affordance in context. A small avatar must not change the
    // leading of the line it sits in.
    HStack(spacing: 4) {
        Text(verbatim: "Assigned to")
        NCUserBubble(displayName: "Lorelai Taylor", user: "lorelai")
        Text(verbatim: "yesterday.")
    }
    .padding()
}

#Preview("UserBubble / dark", traits: .ncTheme) {
    VStack(alignment: .leading, spacing: 8) {
        NCUserBubble(displayName: "Lorelai Taylor", user: "lorelai", status: .away)
        NCUserBubble(displayName: "Zaki Cortes", user: "zaki", action: {})
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("UserBubble / increased contrast", traits: .ncTheme) {
    // `\.colorSchemeContrast` is read-only, so Increase Contrast cannot be
    // forced from code -- toggle it in the canvas accessibility controls. The
    // capsule is `.quaternary`, which the system darkens on its own; the avatar
    // picks its own contrasting foreground.
    VStack(alignment: .leading, spacing: 8) {
        NCUserBubble(displayName: "Lorelai Taylor", user: "lorelai")
        NCUserBubble(displayName: "Zaki Cortes", user: "zaki")
    }
    .padding()
}

#Preview("UserBubble / RTL", traits: .ncTheme) {
    NCUserBubble(displayName: "محمد علي", user: "mohammed", status: .online, action: {}) {
        NCIcon(.close, label: .decorative, size: .small)
    }
    .environment(\.layoutDirection, .rightToLeft)
    .padding()
}

#endif
