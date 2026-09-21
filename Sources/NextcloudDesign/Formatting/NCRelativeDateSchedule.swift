// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import Foundation
public import SwiftUI

/// A `TimelineSchedule` that re-renders a relative date exactly as often as it
/// needs to be.
///
/// The naive alternative -- `.periodic(from: .now, by: 1)` -- wakes the view
/// every second forever, including for a message from last March whose label
/// will not change for another day. This schedule relaxes as the date ages,
/// following ``NCRelativeDateFormatter/refreshInterval(for:relativeTo:)``.
public nonisolated struct NCRelativeDateSchedule: TimelineSchedule, Sendable {
    private let target: Date
    private let formatter: NCRelativeDateFormatter

    public init(target: Date, formatter: NCRelativeDateFormatter = NCRelativeDateFormatter()) {
        self.target = target
        self.formatter = formatter
    }

    public func entries(from startDate: Date, mode: TimelineScheduleMode) -> Entries {
        Entries(current: startDate, target: target, formatter: formatter, mode: mode)
    }

    public struct Entries: Sequence, IteratorProtocol, Sendable {
        fileprivate var current: Date
        fileprivate let target: Date
        fileprivate let formatter: NCRelativeDateFormatter
        fileprivate let mode: TimelineScheduleMode

        public mutating func next() -> Date? {
            let entry = current
            var interval = formatter.refreshInterval(for: target, relativeTo: entry).seconds
            // Low-frequency mode is what SwiftUI asks for when the view is not
            // on screen or the device is conserving power.
            if mode == .lowFrequency {
                interval = Swift.max(interval, 60)
            }
            current = entry.addingTimeInterval(interval)
            return entry
        }
    }
}
