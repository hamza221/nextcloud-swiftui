// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

#Preview("ProgressStyle / roles", traits: .ncTheme) {
    VStack(alignment: .leading, spacing: 16) {
        ProgressView(value: 0.62) {
            Text(verbatim: "offsite-photos.zip")
        } currentValueLabel: {
            Text(verbatim: "62 MB of 100 MB")
        }
        .progressViewStyle(.normal)

        ProgressView(value: 0.4) {
            Text(verbatim: "Retrying — 3 of 12 files")
        }
        .progressViewStyle(.warning)

        ProgressView(value: 0.15) {
            Text(verbatim: "Upload failed — not enough quota")
        }
        .progressViewStyle(.error)
    }
    .frame(width: 280)
    .padding()
}

#Preview("ProgressStyle / bounds", traits: .ncTheme) {
    // Nothing done, everything done, and a value past the total. `.linear`
    // clamps the last one; the style adds no arithmetic of its own.
    VStack(alignment: .leading, spacing: 16) {
        ProgressView(value: 0)
        ProgressView(value: 1)
        ProgressView(value: 2, total: 1)
    }
    .progressViewStyle(.normal)
    .frame(width: 280)
    .padding()
}

#Preview("ProgressStyle / long content", traits: .ncTheme) {
    ProgressView(value: 0.33) {
        Text(verbatim: "Uploading quarterly-planning-final-v7-actually-final.numbers to Documents/Shared")
    } currentValueLabel: {
        Text(verbatim: "33 percent, about four minutes remaining at the current rate")
    }
    .progressViewStyle(.normal)
    .frame(width: 240)
    .padding()
}

#Preview("ProgressStyle / empty", traits: .ncTheme) {
    // No labels, and no bound value at all. The second one is indeterminate,
    // which `.linear` already animates.
    VStack(alignment: .leading, spacing: 16) {
        ProgressView(value: 0.5)
        ProgressView()
    }
    .progressViewStyle(.normal)
    .frame(width: 280)
    .padding()
}

#Preview("ProgressStyle / dark", traits: .ncTheme) {
    VStack(alignment: .leading, spacing: 16) {
        ProgressView(value: 0.62) { Text(verbatim: "offsite-photos.zip") }
            .progressViewStyle(.normal)
        ProgressView(value: 0.15) { Text(verbatim: "Upload failed") }
            .progressViewStyle(.error)
    }
    .frame(width: 280)
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("ProgressStyle / increased contrast", traits: .ncIncreasedContrast) {
    // The system darkens the track and the tint comes from the theme. The style
    // does neither itself.
    VStack(alignment: .leading, spacing: 16) {
        ProgressView(value: 0.62).progressViewStyle(.normal)
        ProgressView(value: 0.62).progressViewStyle(.warning)
        ProgressView(value: 0.62).progressViewStyle(.error)
    }
    .frame(width: 280)
    .padding()
}

#Preview("ProgressStyle / RTL", traits: .ncTheme) {
    // The bar fills from the trailing edge. `.linear` does that; the style is
    // not involved.
    ProgressView(value: 0.62) {
        Text(verbatim: "صور الرحلة.zip")
    } currentValueLabel: {
        Text(verbatim: "٦٢ ٪")
    }
    .progressViewStyle(.normal)
    .environment(\.layoutDirection, .rightToLeft)
    .frame(width: 280)
    .padding()
}

#Preview("ProgressStyle / branded", traits: .ncTheme(brand: NCBrand(primaryHex: "#aa0055") ?? .nextcloud)) {
    // The normal bar follows the instance's brand. Warning and error do not:
    // they are status tokens.
    VStack(alignment: .leading, spacing: 16) {
        ProgressView(value: 0.62).progressViewStyle(.normal)
        ProgressView(value: 0.62).progressViewStyle(.warning)
        ProgressView(value: 0.62).progressViewStyle(.error)
    }
    .frame(width: 280)
    .padding()
}

#endif
