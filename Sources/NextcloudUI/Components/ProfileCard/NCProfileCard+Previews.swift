// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

#Preview("ProfileCard / default", traits: .ncTheme) {
    NCProfileCard(
        displayName: "Lorelai Taylor",
        user: "lorelai",
        status: .online,
        secondaryLines: ["Product design", "lorelai@example.com", "Back on Monday"]
    ) {
        Button(action: {}) { Text(verbatim: "Send message") }
    }
    .frame(width: 280)
    .padding()
}

#Preview("ProfileCard / name only", traits: .ncTheme) {
    NCProfileCard(displayName: "Cher")
        .frame(width: 280)
        .padding()
}

#Preview("ProfileCard / long content", traits: .ncTheme) {
    NCProfileCard(
        displayName: "Ellena Wright Frederic Conway de la Vega-Kowalski",
        user: "ellena",
        status: .doNotDisturb,
        secondaryLines: [
            "Senior staff engineer, platform infrastructure and release tooling",
            "ellena.wright.frederic.conway@a-very-long-instance-name.example.com",
        ]
    ) {
        Button(action: {}) { Text(verbatim: "Send message") }
    }
    .frame(width: 280)
    .padding()
}

#Preview("ProfileCard / empty", traits: .ncTheme) {
    // No name, no lines, no actions. Blank secondary lines are dropped rather
    // than rendered as gaps.
    NCProfileCard(displayName: "", secondaryLines: ["", "   "])
        .frame(width: 280)
        .padding()
}

#Preview("ProfileCard / dark", traits: .ncTheme) {
    NCProfileCard(
        displayName: "Zaki Cortes",
        user: "zaki",
        status: .away,
        secondaryLines: ["Support", "zaki@example.com"]
    ) {
        Button(action: {}) { Text(verbatim: "Send message") }
    }
    .frame(width: 280)
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("ProfileCard / increased contrast", traits: .ncIncreasedContrast) {
    // The secondary lines are `.secondary`, which the system handles.
    NCProfileCard(
        displayName: "Tom Mörtel",
        user: "tom",
        secondaryLines: ["Operations"]
    )
    .frame(width: 280)
    .padding()
}

#Preview("ProfileCard / RTL", traits: .ncTheme) {
    NCProfileCard(
        displayName: "محمد علي",
        user: "mohammed",
        status: .online,
        secondaryLines: ["مهندس برمجيات", "mohammed@example.com"]
    ) {
        Button(action: {}) { Text(verbatim: "إرسال رسالة") }
    }
    .environment(\.layoutDirection, .rightToLeft)
    .frame(width: 280)
    .padding()
}

#endif
