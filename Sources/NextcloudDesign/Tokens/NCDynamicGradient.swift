// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

internal import Foundation
public import SwiftUI

/// One stop of an ``NCDynamicGradient``.
///
/// `location` follows the CSS authoring convention and may fall outside `0...1`;
/// Nextcloud's assistant border gradient ends at 125%, meaning its final colour
/// is never fully reached inside the box. ``NCDynamicGradient`` trims such stops
/// by interpolation rather than clamping, which would reach the end colour early
/// and visibly change the ramp.
public nonisolated struct NCGradientStop: Hashable, Sendable {
    public var color: NCRGB
    public var location: Double

    public init(color: NCRGB, location: Double) {
        self.color = color
        self.location = location
    }

    /// Creates a stop from a packed `0xRRGGBB` value and a percentage.
    internal init(_ packed: UInt32, _ percent: Double) {
        self.init(color: NCRGB(packed: packed), location: percent / 100)
    }
}

/// A gradient token with light and dark variants.
///
/// Reserved for AI-generated content. Nextcloud uses a gradient specifically to
/// mark assistant surfaces, and it is the one place in the system where a flat
/// token will not do.
public nonisolated struct NCDynamicGradient: ShapeStyle, Hashable, Sendable {
    /// The direction in a light appearance, in CSS terms: zero points to the top
    /// of the box and increases clockwise.
    public var lightAngle: Angle
    /// The direction in a dark appearance.
    ///
    /// Nextcloud rotates several assistant gradients for dark mode -- the
    /// primary element goes from 214 to 238 degrees, the icon from 214 to 285 --
    /// so this is a separate value rather than a shared one.
    public var darkAngle: Angle
    public var lightStops: [NCGradientStop]
    public var darkStops: [NCGradientStop]

    public init(
        lightAngle: Angle,
        darkAngle: Angle? = nil,
        lightStops: [NCGradientStop],
        darkStops: [NCGradientStop]
    ) {
        self.lightAngle = lightAngle
        self.darkAngle = darkAngle ?? lightAngle
        self.lightStops = lightStops
        self.darkStops = darkStops
    }

    /// The direction for an appearance.
    public func angle(for scheme: ColorScheme) -> Angle {
        scheme == .dark ? darkAngle : lightAngle
    }

    /// The stops for an appearance, trimmed to `0...1`.
    public func stops(for scheme: ColorScheme) -> [NCGradientStop] {
        Self.trimmedToUnitRange(scheme == .dark ? darkStops : lightStops)
    }

    /// The gradient for an appearance.
    public func gradient(for scheme: ColorScheme) -> LinearGradient {
        let (start, end) = Self.unitPoints(for: angle(for: scheme))
        return LinearGradient(
            stops: stops(for: scheme).map {
                Gradient.Stop(color: $0.color.color, location: $0.location)
            },
            startPoint: start,
            endPoint: end
        )
    }

    // MARK: ShapeStyle

    public func resolve(in environment: EnvironmentValues) -> LinearGradient {
        gradient(for: environment.colorScheme)
    }

    // MARK: Geometry

    /// Converts a CSS gradient angle into SwiftUI start and end unit points.
    ///
    /// CSS measures from "to top", clockwise; SwiftUI takes two points in a unit
    /// square whose y axis grows downward. The line is scaled so that it spans
    /// the box edge to edge.
    internal static func unitPoints(for angle: Angle) -> (start: UnitPoint, end: UnitPoint) {
        let radians = angle.radians
        let dx = sin(radians)
        let dy = -cos(radians)
        let magnitude = max(abs(dx), abs(dy))
        guard magnitude > 0 else { return (.top, .bottom) }
        let scale = 0.5 / magnitude
        return (
            start: UnitPoint(x: 0.5 - dx * scale, y: 0.5 - dy * scale),
            end: UnitPoint(x: 0.5 + dx * scale, y: 0.5 + dy * scale)
        )
    }

    /// Trims stops to `0...1`, interpolating a boundary stop where the ramp
    /// crosses it and holding the end colours flat outside the authored range.
    internal static func trimmedToUnitRange(_ stops: [NCGradientStop]) -> [NCGradientStop] {
        let sorted = stops.sorted { $0.location < $1.location }
        guard let first = sorted.first else { return [] }
        guard sorted.count > 1 else {
            return [
                NCGradientStop(color: first.color, location: 0),
                NCGradientStop(color: first.color, location: 1),
            ]
        }

        var result = [NCGradientStop(color: colour(of: sorted, at: 0), location: 0)]
        result.append(contentsOf: sorted.filter { $0.location > 0 && $0.location < 1 })
        result.append(NCGradientStop(color: colour(of: sorted, at: 1), location: 1))
        return result
    }

    /// The colour of a sorted ramp at a location, interpolated in sRGB as CSS
    /// does by default, and held flat beyond either end.
    private static func colour(of sorted: [NCGradientStop], at location: Double) -> NCRGB {
        guard let first = sorted.first, let last = sorted.last else { return .black }
        if location <= first.location { return first.color }
        if location >= last.location { return last.color }

        for (lower, upper) in zip(sorted, sorted.dropFirst()) {
            guard location >= lower.location, location <= upper.location else { continue }
            let span = upper.location - lower.location
            let fraction = span > 0 ? (location - lower.location) / span : 0
            return NCRGB(
                red: lower.color.red + (upper.color.red - lower.color.red) * fraction,
                green: lower.color.green + (upper.color.green - lower.color.green) * fraction,
                blue: lower.color.blue + (upper.color.blue - lower.color.blue) * fraction
            )
        }
        return last.color
    }
}

/// Gradients and surfaces reserved for AI-generated content.
///
/// Transcribed from the `--color-*-assistant` custom properties. The components
/// that use these are deferred to v1.1, pending settled Liquid Glass conventions
/// for AI affordances, but the tokens are transcribed now so the two land
/// together.
public nonisolated struct NCAssistantColors: Hashable, Sendable {
    /// The background behind AI-generated content.
    public var background: NCDynamicColor
    /// The border around AI-generated content.
    public var border: NCDynamicGradient
    /// The fill of a primary control that invokes the assistant.
    public var element: NCDynamicGradient
    /// Reserved for the assistant icon itself.
    public var icon: NCDynamicGradient

    public init(
        background: NCDynamicColor,
        border: NCDynamicGradient,
        element: NCDynamicGradient,
        icon: NCDynamicGradient
    ) {
        self.background = background
        self.border = border
        self.element = element
        self.icon = icon
    }

    public static let nextcloud = NCAssistantColors(
        background: NCDynamicColor(light: 0xF6F5_FF, dark: 0x221D_2B),
        border: NCDynamicGradient(
            lightAngle: .degrees(125),
            lightStops: [NCGradientStop(0x7398_FE, 50), NCGradientStop(0x6104_A4, 125)],
            darkStops: [NCGradientStop(0x0C3A_65, 50), NCGradientStop(0x6204_A5, 125)]
        ),
        element: NCDynamicGradient(
            lightAngle: .degrees(214),
            darkAngle: .degrees(238),
            lightStops: [
                NCGradientStop(0xA569_D3, 12),
                NCGradientStop(0x0067_9E, 39),
                NCGradientStop(0x4220_83, 86),
            ],
            darkStops: [
                NCGradientStop(0xA569_D3, 12),
                NCGradientStop(0x0067_9E, 39),
                NCGradientStop(0x4220_83, 86),
            ]
        ),
        icon: NCDynamicGradient(
            lightAngle: .degrees(214),
            darkAngle: .degrees(285),
            lightStops: [
                NCGradientStop(0x9669_D3, 15),
                NCGradientStop(0x0067_9E, 40),
                NCGradientStop(0x4920_83, 80),
            ],
            darkStops: [
                NCGradientStop(0xCDAC_E7, 15.28),
                NCGradientStop(0x008F_DB, 39.98),
                NCGradientStop(0xA180_E0, 82.05),
            ]
        )
    )
}
