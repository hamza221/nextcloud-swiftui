// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

internal import CryptoKit
public import SwiftUI

/// Maps a user identifier to a stable colour from ``NCAvatarPalette``.
///
/// A port of `src/functions/usernameToColor/index.ts` from `@nextcloud/vue`,
/// and the one piece of this package that is required to agree with the web
/// implementation exactly rather than approximately. `Tests/NextcloudDesignTests`
/// pins it against the upstream Vitest snapshot.
///
/// ```swift
/// let colour = NCUsernameColor.color(for: "admin")   // #d09e6d
/// ```
public nonisolated enum NCUsernameColor {
    /// The colour for a display name or user id.
    public static func rgb(for username: String) -> NCRGB {
        let palette = NCAvatarPalette.standard
        let index = hashCode(username.lowercased()) % palette.count
        return palette[index]
    }

    /// The colour for a display name or user id, as a SwiftUI colour.
    public static func color(for username: String) -> Color {
        rgb(for: username).color
    }

    /// Sums the base-16 value of every hex digit of the identifier's MD5.
    ///
    /// An identifier that already looks like an MD5 (or a federated cloud id,
    /// which shares that shape) is used directly instead of being hashed again.
    /// Dropping that skip would recolour every federated contact relative to the
    /// web client, so it is preserved deliberately.
    internal static func hashCode(_ identifier: String) -> Int {
        let digest: String =
            hasMD5Shape(identifier)
            ? identifier
            : md5Hex(identifier)

        // Equivalent to `.replace(/[^0-9a-f]/g, '')` followed by summing
        // `parseInt(char, 16)`. Deliberately not `Character.isHexDigit`, which
        // also accepts A-F and full-width forms that the JS character class
        // would have stripped.
        return digest.reduce(into: 0) { total, character in
            if let value = lowercaseHexValue(character) { total += value }
        }
    }

    /// Matches `^([0-9a-f]{4}-?){8}$`: eight groups of four lowercase hex
    /// digits, each optionally followed by a hyphen.
    ///
    /// Hand-written rather than a `Regex` so that this target keeps its
    /// Foundation-free import surface. Greedy hyphen consumption is equivalent to
    /// the regex engine's, because a hyphen can never begin the following group.
    internal static func hasMD5Shape(_ value: String) -> Bool {
        var index = value.startIndex
        for _ in 0..<8 {
            for _ in 0..<4 {
                guard index < value.endIndex, lowercaseHexValue(value[index]) != nil else {
                    return false
                }
                index = value.index(after: index)
            }
            if index < value.endIndex, value[index] == "-" {
                index = value.index(after: index)
            }
        }
        return index == value.endIndex
    }

    private static func lowercaseHexValue(_ character: Character) -> Int? {
        guard let ascii = character.asciiValue else { return nil }
        switch ascii {
        case 0x30...0x39: return Int(ascii - 0x30)  // 0-9
        case 0x61...0x66: return Int(ascii - 0x61) + 10  // a-f
        default: return nil
        }
    }

    /// The lowercase hex MD5 of the identifier's UTF-8 bytes.
    ///
    /// MD5 is not a security choice here: it is the hash the Nextcloud server
    /// and the web client already agree on, so `Insecure` is the correct and
    /// only usable API.
    private static func md5Hex(_ value: String) -> String {
        Insecure.MD5.hash(data: Array(value.utf8))
            .reduce(into: "") { output, byte in
                output.append(hexDigits[Int(byte >> 4)])
                output.append(hexDigits[Int(byte & 0x0F)])
            }
    }

    private static let hexDigits = Array("0123456789abcdef")
}
