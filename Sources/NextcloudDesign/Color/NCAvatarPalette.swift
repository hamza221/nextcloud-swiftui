// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

/// The Nextcloud colour wheel.
///
/// A port of `src/utils/colors.ts` from `@nextcloud/vue`. Three base colours are
/// blended pairwise into a ring, so that any two adjacent entries are visually
/// close and the ring as a whole has no discontinuity.
///
/// This must stay bit-for-bit identical to the web implementation: the palette
/// indexes avatar colours, and a person who shows up teal in the web client and
/// purple in the native one looks like two different people.
public nonisolated enum NCAvatarPalette {
    /// `RGB(182, 70, 157)`. Named "Purple" upstream despite the variable being
    /// called `COLOR_RED`.
    public static let basePurple = NCRGB(red8: 182, green8: 70, blue8: 157)
    /// `RGB(221, 203, 85)`, "Gold".
    public static let baseGold = NCRGB(red8: 221, green8: 203, blue8: 85)
    /// `RGB(0, 130, 201)`, "Nextcloud blue".
    public static let baseBlue = NCRGB(red8: 0, green8: 130, blue8: 201)

    /// The 18-entry palette that ``NCUsernameColor`` indexes into.
    ///
    /// Computed once; `generate(steps:)` remains available for callers that want
    /// a coarser or finer ring.
    public static let standard: [NCRGB] = generate(steps: 6)

    /// Blends the three base colours into a ring of `3 * steps` entries.
    ///
    /// - Parameter steps: Entries per blend. Values of zero or less are coerced
    ///   to six, matching upstream.
    ///
    /// - Note: Upstream short-circuits `steps == 4` to a hand-written array so it
    ///   can attach translated colour names. That array is numerically identical
    ///   to what this function computes, so there is no special case here; the
    ///   names are a web-styleguide concern and are not ported.
    public static func generate(steps: Int) -> [NCRGB] {
        let steps = steps <= 0 ? 6 : steps
        return blend(steps: steps, from: basePurple, to: baseGold)
            + blend(steps: steps, from: baseGold, to: baseBlue)
            + blend(steps: steps, from: baseBlue, to: basePurple)
    }

    /// One leg of the ring: `from`, then `steps - 1` interpolated entries.
    ///
    /// The truncation is load-bearing. Upstream uses `Math.floor` on each channel
    /// of each intermediate step, so rounding to nearest here would shift several
    /// palette entries by one and break parity.
    private static func blend(steps: Int, from start: NCRGB, to end: NCRGB) -> [NCRGB] {
        let (r0, g0, b0) = start.components8
        let (r1, g1, b1) = end.components8
        let stepR = Double(r1 - r0) / Double(steps)
        let stepG = Double(g1 - g0) / Double(steps)
        let stepB = Double(b1 - b0) / Double(steps)

        var palette = [start]
        palette.reserveCapacity(steps)
        for index in 1..<steps {
            let offset = Double(index)
            palette.append(
                NCRGB(
                    red8: floored(Double(r0) + stepR * offset),
                    green8: floored(Double(g0) + stepG * offset),
                    blue8: floored(Double(b0) + stepB * offset)
                )
            )
        }
        return palette
    }

    private static func floored(_ value: Double) -> Int {
        Int(value.rounded(.down))
    }
}
