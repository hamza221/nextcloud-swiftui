// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// A plain sRGB colour value.
///
/// This is the currency of the package's colour maths: palette generation,
/// contrast computation and brand derivation all operate on `NCRGB` rather than
/// on `SwiftUI.Color`, because `Color` deliberately does not expose its
/// components outside of a rendering environment.
///
/// It is `nonisolated` so that it stays callable off the main actor even though
/// the package builds with `defaultIsolation(MainActor.self)`.
public nonisolated struct NCRGB: Hashable, Sendable {
    /// Red, in `0...1`.
    public let red: Double
    /// Green, in `0...1`.
    public let green: Double
    /// Blue, in `0...1`.
    public let blue: Double

    /// Creates a colour from unit components, clamping each to `0...1`.
    public init(red: Double, green: Double, blue: Double) {
        self.red = red.clampedToUnit
        self.green = green.clampedToUnit
        self.blue = blue.clampedToUnit
    }

    /// Creates a colour from 8-bit components, clamping each to `0...255`.
    ///
    /// - Note: `@nextcloud/vue`'s `Color` clamps only the upper bound. The
    ///   difference is unobservable for the palette, whose components are always
    ///   interpolations between two in-range endpoints, but it is worth knowing
    ///   if this initialiser is ever fed arbitrary arithmetic.
    public init(red8: Int, green8: Int, blue8: Int) {
        self.init(
            red: Double(red8) / 255,
            green: Double(green8) / 255,
            blue: Double(blue8) / 255
        )
    }

    /// Parses `#RRGGBB`, `RRGGBB`, `#RGB` or `RGB`.
    ///
    /// Returns `nil` rather than trapping on malformed input: brand colours
    /// arrive over the network from a server's capabilities response, and a
    /// misconfigured instance must not crash the client.
    public init?(hex: String) {
        var digits = Substring(hex)
        if digits.hasPrefix("#") { digits = digits.dropFirst() }
        guard digits.allSatisfy(\.isHexDigit) else { return nil }

        let value: UInt32
        switch digits.count {
        case 3:
            // #abc expands to #aabbcc.
            guard let short = UInt32(digits, radix: 16) else { return nil }
            let r = (short & 0xF00) >> 8
            let g = (short & 0x0F0) >> 4
            let b = short & 0x00F
            value = (r << 20) | (r << 16) | (g << 12) | (g << 8) | (b << 4) | b
        case 6:
            guard let full = UInt32(digits, radix: 16) else { return nil }
            value = full
        default:
            return nil
        }
        self.init(packed: value)
    }

    /// Creates a colour from a packed `0xRRGGBB` value.
    public init(packed value: UInt32) {
        self.init(
            red8: Int((value >> 16) & 0xFF),
            green8: Int((value >> 8) & 0xFF),
            blue8: Int(value & 0xFF)
        )
    }

    /// The 8-bit components, rounded to nearest.
    public var components8: (red: Int, green: Int, blue: Int) {
        (Int((red * 255).rounded()), Int((green * 255).rounded()), Int((blue * 255).rounded()))
    }

    /// The lowercase `#rrggbb` representation, matching the hex form
    /// `@nextcloud/vue` produces.
    public var hexString: String {
        let (r, g, b) = components8
        return "#" + Self.hexByte(r) + Self.hexByte(g) + Self.hexByte(b)
    }

    private static func hexByte(_ value: Int) -> String {
        let digits = "0123456789abcdef"
        let high = digits[digits.index(digits.startIndex, offsetBy: (value >> 4) & 0xF)]
        let low = digits[digits.index(digits.startIndex, offsetBy: value & 0xF)]
        return String(high) + String(low)
    }

    /// The SwiftUI colour, in the sRGB colour space.
    public var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}

nonisolated extension NCRGB: CustomStringConvertible {
    public var description: String { hexString }
}

nonisolated extension Double {
    fileprivate var clampedToUnit: Double { Swift.min(Swift.max(self, 0), 1) }
}

nonisolated extension NCRGB {
    /// Blends toward another colour in sRGB, the space CSS interpolates in by
    /// default.
    ///
    /// - Parameter amount: `0` returns the receiver, `1` returns `other`.
    public func mixed(with other: NCRGB, amount: Double) -> NCRGB {
        let t = Swift.min(Swift.max(amount, 0), 1)
        return NCRGB(
            red: red + (other.red - red) * t,
            green: green + (other.green - green) * t,
            blue: blue + (other.blue - blue) * t
        )
    }
}
