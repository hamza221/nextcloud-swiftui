// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

internal import Foundation

/// WCAG 2.1 contrast maths.
///
/// This replaces the colour arithmetic the Nextcloud server does in PHP when it
/// derives a readable foreground for an instance's brand colour. Having it here
/// means the package can derive `onPrimary` itself when a server does not report
/// one, instead of shipping unreadable text on a dark brand.
public nonisolated enum NCContrast {
    /// The minimum ratio WCAG 2.1 requires of body text (AA, 1.4.3).
    public static let aaNormalText: Double = 4.5
    /// The minimum ratio WCAG 2.1 requires of large text (AA, 1.4.3).
    public static let aaLargeText: Double = 3.0
    /// The minimum ratio WCAG 2.1 requires of UI component boundaries (AA, 1.4.11).
    public static let aaNonText: Double = 3.0
    /// The minimum ratio WCAG 2.1 requires of body text (AAA, 1.4.6).
    public static let aaaNormalText: Double = 7.0

    /// Relative luminance, per WCAG 2.1's definition.
    ///
    /// Note that this linearises each channel first; a plain weighted average of
    /// the sRGB components is a common and wrong shortcut that overstates the
    /// brightness of saturated blues, which matters a lot here because the
    /// default Nextcloud brand colour is one.
    public static func relativeLuminance(of colour: NCRGB) -> Double {
        0.2126 * linearise(colour.red)
            + 0.7152 * linearise(colour.green)
            + 0.0722 * linearise(colour.blue)
    }

    /// The contrast ratio between two colours, in `1...21`.
    ///
    /// The result is symmetric: argument order does not matter.
    public static func ratio(_ first: NCRGB, _ second: NCRGB) -> Double {
        let a = relativeLuminance(of: first)
        let b = relativeLuminance(of: second)
        let lighter = Swift.max(a, b)
        let darker = Swift.min(a, b)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Whether two colours meet a contrast threshold.
    public static func meets(
        _ threshold: Double,
        _ first: NCRGB,
        _ second: NCRGB
    ) -> Bool {
        ratio(first, second) >= threshold
    }

    /// The candidate that contrasts most strongly with `background`.
    ///
    /// Used to derive a foreground for a brand colour. Defaults to plain white
    /// and black, which is what the server picks between.
    public static func preferredForeground(
        on background: NCRGB,
        candidates: [NCRGB] = [.white, .black]
    ) -> NCRGB {
        candidates.max { ratio($0, background) < ratio($1, background) } ?? .white
    }

    private static func linearise(_ channel: Double) -> Double {
        channel <= 0.039_28
            ? channel / 12.92
            : pow((channel + 0.055) / 1.055, 2.4)
    }
}

nonisolated extension NCRGB {
    /// Opaque white.
    public static let white = NCRGB(red: 1, green: 1, blue: 1)
    /// Opaque black.
    public static let black = NCRGB(red: 0, green: 0, blue: 0)
}
