// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import Foundation
public import SwiftUI

/// Relative time in Nextcloud's phrasing.
///
/// A port of `useFormatRelativeTime` from `@nextcloud/vue`. The formatting
/// itself is `Date.RelativeFormatStyle`, which already matches the web's
/// `Intl.RelativeTimeFormat` with `numeric: "auto"`. What is ported is the two
/// behaviours around it that are Nextcloud's own: suppressing second-level
/// precision, and the refresh cadence.
public nonisolated struct NCRelativeDateFormatter: Hashable, Sendable {
    /// How much room the string is given.
    public enum Width: Hashable, Sendable, CaseIterable {
        /// "2 minutes ago"
        case long
        /// "2 min. ago"
        case short
        /// "2m ago"
        case narrow

        fileprivate var unitsStyle: Date.RelativeFormatStyle.UnitsStyle {
            switch self {
            case .long: .wide
            case .short: .abbreviated
            case .narrow: .narrow
            }
        }

        fileprivate var fewSecondsKey: String.LocalizationValue {
            switch self {
            case .long: "a few seconds ago"
            case .short: "seconds ago"
            case .narrow: "sec. ago"
            }
        }
    }

    public var width: Width
    /// Whether to collapse everything under a minute into "a few seconds ago".
    ///
    /// A ticking second counter draws the eye away from the content; Nextcloud
    /// turns it off in list contexts.
    public var ignoresSeconds: Bool
    public var locale: Locale

    public init(
        width: Width = .long,
        ignoresSeconds: Bool = false,
        locale: Locale = .autoupdatingCurrent
    ) {
        self.width = width
        self.ignoresSeconds = ignoresSeconds
        self.locale = locale
    }

    /// The relative description of `date` as seen from `reference`.
    public func string(for date: Date, relativeTo reference: Date = .now) -> String {
        let interval = date.timeIntervalSince(reference)
        guard interval.isFinite else {
            return String(localized: LocalizedStringResource(ncDesign: "Invalid date"))
        }

        if ignoresSeconds, abs(interval) < 60 {
            return String(localized: LocalizedStringResource(ncDesign: width.fewSecondsKey))
        }

        let style = Date.RelativeFormatStyle(
            presentation: .named,
            unitsStyle: width.unitsStyle,
            locale: locale,
            calendar: Calendar(identifier: locale.calendar.identifier),
            capitalizationContext: .middleOfSentence
        )
        return date.formatted(style)
    }

    /// How long the rendered string stays accurate.
    ///
    /// Ported from upstream: under two minutes the string is refreshed every
    /// second, and beyond that the cadence relaxes in proportion to the age of
    /// the date, capped at thirty minutes. A week-old message is not re-rendered
    /// every second to keep a string that will not change for another day.
    public func refreshInterval(
        for date: Date,
        relativeTo reference: Date = .now
    ) -> Duration {
        let age = abs(date.timeIntervalSince(reference))
        guard age.isFinite else { return .seconds(Self.maximumRefreshInterval) }

        if age <= Self.secondPrecisionWindow, !ignoresSeconds {
            return .seconds(1)
        }
        let relaxed = min(age / 60, Self.maximumRefreshInterval)
        return .seconds(max(relaxed, 1))
    }

    /// Upstream's 120 000 ms threshold.
    private static let secondPrecisionWindow: TimeInterval = 120
    /// Upstream's 1 800 000 ms cap.
    private static let maximumRefreshInterval: TimeInterval = 1800
}
