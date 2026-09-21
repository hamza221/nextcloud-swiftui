// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

#Preview("Chip / roles", traits: .ncTheme) {
    VStack(alignment: .leading, spacing: 8) {
        ForEach(NCChip<EmptyView>.Role.allCases, id: \.self) { role in
            NCChip("Lorelai Taylor", role: role)
        }
    }
    .padding()
}

#Preview("Chip / removable", traits: .ncTheme) {
    HStack {
        NCChip("lorelai@example.com", role: .primary, onRemove: {})
        NCChip("Tom Mörtel", onRemove: {})
    }
    .padding()
}

#Preview("Chip / long content", traits: .ncTheme) {
    NCChip(
        "ellena.wright.frederic.conway@a-very-long-instance-name.example.com",
        role: .primary,
        onRemove: {}
    )
    .frame(width: 240)
    .padding()
}

#Preview("Chip / with leading avatar", traits: .ncTheme) {
    NCChip("Zaki Cortes", role: .primary) {
        Circle()
            .fill(NCUsernameColor.color(for: "Zaki Cortes"))
            .frame(width: 16, height: 16)
    }
    .padding()
}

#Preview("Chip / RTL", traits: .ncTheme) {
    NCChip("مرحبا بالعالم", role: .primary, onRemove: {})
        .environment(\.layoutDirection, .rightToLeft)
        .padding()
}

#Preview("Chip / branded", traits: .ncTheme(brand: NCBrand(primaryHex: "#aa0055") ?? .nextcloud)) {
    // Checks that the chip reads its tokens rather than hard-coding
    // Nextcloud blue.
    NCChip("Instance branding", role: .primary).padding()
}

#Preview("Chip / increased contrast", traits: .ncIncreasedContrast) {
    // The primary role is the one at risk: its text sits on a derived surface
    // token rather than on a system material.
    VStack(alignment: .leading, spacing: 8) {
        ForEach(NCChip<EmptyView>.Role.allCases, id: \.self) { role in
            NCChip("Lorelai Taylor", role: role, onRemove: {})
        }
    }
    .padding()
}

#endif
