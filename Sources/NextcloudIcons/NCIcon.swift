// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import NextcloudDesign
public import SwiftUI

/// A Material Design Icon.
///
/// Sized from ``NCIcon/Size`` rather than a literal, and tinted by whatever
/// `.foregroundStyle` is in effect -- an icon never picks its own colour.
///
/// The accessibility label is a required argument. Most icons sit beside a text
/// label that already carries the meaning, and ``NCAccessibilityLabel/decorative``
/// is the right answer there, but it has to be chosen rather than forgotten.
public struct NCIcon: View {
    private let symbol: NCSymbol
    private let label: NCAccessibilityLabel
    private let size: Size

    @Environment(\.ncTheme) private var theme

    /// How much room the icon takes.
    public enum Size: Hashable, Sendable, CaseIterable {
        /// Inline with small text, or inside a chip.
        case small
        /// The default: a list row or a toolbar.
        case medium
        /// A header, or an empty-state illustration.
        case large

        fileprivate func dimension(_ metrics: NCMetrics) -> CGFloat {
            switch self {
            case .small: metrics.icon.small
            case .medium: metrics.icon.medium
            case .large: metrics.icon.large
            }
        }
    }

    public init(_ symbol: NCSymbol, label: NCAccessibilityLabel, size: Size = .medium) {
        self.symbol = symbol
        self.label = label
        self.size = size
    }

    public var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: dimension, height: dimension)
            .ncAccessibilityLabel(label)
    }

    private var dimension: CGFloat { size.dimension(theme.metrics) }

    private var image: Image {
        if symbol.hasBundledAsset {
            Image(symbol.asset, bundle: .module)
        } else if let systemFallback = symbol.systemFallback {
            Image(systemName: systemFallback)
        } else {
            // Deliberately conspicuous. A symbol with neither a generated asset
            // nor a system equivalent -- a brand logo, usually -- should be
            // visible as missing in the showcase rather than render as a blank
            // gap that nobody notices until a screenshot review.
            Image(systemName: "questionmark.square.dashed")
        }
    }
}
