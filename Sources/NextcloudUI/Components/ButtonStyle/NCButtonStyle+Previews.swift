// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

/// Every role at once, so that a change to one is visible against the others.
private struct NCButtonStyleGallery: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {}) { Text(verbatim: "Send") }
                .buttonStyle(.primary)
            Button(action: {}) { Text(verbatim: "Save draft") }
                .buttonStyle(.secondary)
            Button(action: {}) { Text(verbatim: "Cancel") }
                .buttonStyle(.tertiary)
            Button(role: .destructive, action: {}) { Text(verbatim: "Delete message") }
                .buttonStyle(.error)
            Button(action: {}) {
                Label {
                    Text(verbatim: "Archive")
                } icon: {
                    NCIcon(.folderOutline, label: .decorative)
                }
            }
            .buttonStyle(.icon)
        }
        .padding()
    }
}

#Preview("ButtonStyle / roles", traits: .ncTheme) {
    NCButtonStyleGallery()
}

#Preview("ButtonStyle / long content", traits: .ncTheme) {
    // A label longer than its container. The system styles truncate and keep
    // their shape; nothing here has to help.
    VStack(spacing: 12) {
        Button(action: {}) {
            Text(verbatim: "Send to everyone in the quarterly planning distribution list")
        }
        .buttonStyle(.primary)
        Button(action: {}) {
            Text(verbatim: "Move to an archive folder with a very long name indeed")
        }
        .buttonStyle(.secondary)
    }
    .frame(width: 220)
    .padding()
}

#Preview("ButtonStyle / empty", traits: .ncTheme) {
    // An empty label and a disabled button: the two states a role has to
    // survive without collapsing or losing its tint.
    VStack(spacing: 12) {
        Button(action: {}) { Text(verbatim: "") }
            .buttonStyle(.primary)
        Button(action: {}) { Text(verbatim: "Send") }
            .buttonStyle(.primary)
            .disabled(true)
        Button(action: {}) { Text(verbatim: "Delete") }
            .buttonStyle(.error)
            .disabled(true)
    }
    .padding()
}

#Preview("ButtonStyle / dark", traits: .ncTheme) {
    NCButtonStyleGallery()
        .preferredColorScheme(.dark)
}

#Preview("ButtonStyle / increased contrast", traits: .ncIncreasedContrast) {
    // The system styles redraw their own borders and fills. All this style
    // contributes is the tint.
    NCButtonStyleGallery()
}

#Preview("ButtonStyle / RTL", traits: .ncTheme) {
    VStack(alignment: .leading, spacing: 12) {
        Button(action: {}) { Text(verbatim: "إرسال") }
            .buttonStyle(.primary)
        Button(action: {}) { Text(verbatim: "إلغاء") }
            .buttonStyle(.tertiary)
        Button(action: {}) {
            Label {
                Text(verbatim: "أرشفة")
            } icon: {
                NCIcon(.folderOutline, label: .decorative)
            }
        }
        .buttonStyle(.icon)
    }
    .environment(\.layoutDirection, .rightToLeft)
    .padding()
}

#Preview("ButtonStyle / accent policies", traits: .ncTheme) {
    // The same three buttons under each policy. Under `.system` the brand tint
    // is absent and the buttons take the user's macOS accent, which is the
    // whole point of the policy.
    HStack(alignment: .top, spacing: 20) {
        ForEach(NCAccentPolicy.allCases, id: \.self) { policy in
            VStack(spacing: 8) {
                Text(verbatim: String(describing: policy)).font(.caption)
                Button(action: {}) { Text(verbatim: "Send") }
                    .buttonStyle(.primary)
                Button(action: {}) { Text(verbatim: "Cancel") }
                    .buttonStyle(.tertiary)
                Button(action: {}) { Text(verbatim: "Delete") }
                    .buttonStyle(.error)
            }
            .ncTheme(NCTheme(accentPolicy: policy))
        }
    }
    .padding()
}

#Preview("ButtonStyle / branded", traits: .ncTheme(brand: NCBrand(primaryHex: "#aa0055") ?? .nextcloud)) {
    // Checks that the roles read their tokens rather than hard-coding
    // Nextcloud blue. The error button must stay red: it is a status token.
    NCButtonStyleGallery()
}

#endif
