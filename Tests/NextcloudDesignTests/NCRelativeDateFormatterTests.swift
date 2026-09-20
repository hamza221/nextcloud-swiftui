// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing

@testable import NextcloudDesign

@Suite("Relative dates")
struct NCRelativeDateFormatterTests {
    private let reference = Date(timeIntervalSince1970: 1_700_000_000)

    @Test("refreshes every second inside the two-minute window")
    func secondPrecisionWindow() {
        let formatter = NCRelativeDateFormatter()
        for age in [0.0, 1, 30, 119] {
            let date = reference.addingTimeInterval(-age)
            #expect(formatter.refreshInterval(for: date, relativeTo: reference) == .seconds(1))
        }
    }

    /// Upstream relaxes the cadence in proportion to the age of the date, capped
    /// at thirty minutes. A week-old message must not wake the view every second
    /// to keep a label that will not change for another day.
    @Test("relaxes the cadence as the date ages, capped at thirty minutes")
    func relaxedCadence() {
        let formatter = NCRelativeDateFormatter()

        // 1 hour old -> 3600/60 = 60s.
        #expect(
            formatter.refreshInterval(for: reference.addingTimeInterval(-3600), relativeTo: reference)
                == .seconds(60)
        )
        // 1 day old -> 86400/60 = 1440s, still under the cap.
        #expect(
            formatter.refreshInterval(for: reference.addingTimeInterval(-86400), relativeTo: reference)
                == .seconds(1440)
        )
        // 1 week old -> capped at 1800s.
        #expect(
            formatter.refreshInterval(for: reference.addingTimeInterval(-604_800), relativeTo: reference)
                == .seconds(1800)
        )
    }

    @Test("skips the per-second cadence when seconds are suppressed")
    func ignoringSecondsRelaxesImmediately() {
        // At 100s old the two configurations disagree: the default is still
        // inside the two-minute window and ticks every second, while suppressing
        // seconds relaxes straight to 100/60s.
        let age = reference.addingTimeInterval(-100)
        let ticking = NCRelativeDateFormatter().refreshInterval(for: age, relativeTo: reference)
        let relaxed = NCRelativeDateFormatter(ignoresSeconds: true)
            .refreshInterval(for: age, relativeTo: reference)

        #expect(ticking == .seconds(1))
        #expect(relaxed > ticking)
    }

    @Test("never returns a non-positive interval")
    func intervalIsAlwaysPositive() {
        let formatter = NCRelativeDateFormatter(ignoresSeconds: true)
        #expect(formatter.refreshInterval(for: reference, relativeTo: reference) >= .seconds(1))
    }

    @Test("treats future dates by magnitude, like upstream's Math.abs")
    func futureDatesUseMagnitude() {
        let formatter = NCRelativeDateFormatter()
        let past = formatter.refreshInterval(for: reference.addingTimeInterval(-3600), relativeTo: reference)
        let future = formatter.refreshInterval(for: reference.addingTimeInterval(3600), relativeTo: reference)
        #expect(past == future)
    }

    @Test("collapses sub-minute ages when seconds are suppressed")
    func ignoresSecondsCollapsesLabel() {
        let formatter = NCRelativeDateFormatter(ignoresSeconds: true, locale: Locale(identifier: "en_US"))
        let label = formatter.string(for: reference.addingTimeInterval(-5), relativeTo: reference)
        // The exact wording is translated; what matters is that no second count
        // leaked into it.
        #expect(!label.contains("5"))
    }

    @Test("still counts seconds when they are not suppressed")
    func secondsAreShownByDefault() {
        let formatter = NCRelativeDateFormatter(locale: Locale(identifier: "en_US"))
        let label = formatter.string(for: reference.addingTimeInterval(-5), relativeTo: reference)
        #expect(!label.isEmpty)
    }

    @Test("schedules entries at the interval it advertises")
    func scheduleFollowsTheFormatter() {
        let formatter = NCRelativeDateFormatter()
        let target = reference.addingTimeInterval(-3600)
        let schedule = NCRelativeDateSchedule(target: target, formatter: formatter)
        let entries = Array(schedule.entries(from: reference, mode: .normal).prefix(3))

        #expect(entries.count == 3)
        #expect(entries[0] == reference)
        // 1 hour old -> 60s steps.
        #expect(abs(entries[1].timeIntervalSince(entries[0]) - 60) < 0.001)
    }

    @Test("slows down further in low-frequency mode")
    func lowFrequencyModeIsSlower() {
        let formatter = NCRelativeDateFormatter()
        let target = reference.addingTimeInterval(-10)
        let schedule = NCRelativeDateSchedule(target: target, formatter: formatter)

        let normal = Array(schedule.entries(from: reference, mode: .normal).prefix(2))
        let low = Array(schedule.entries(from: reference, mode: .lowFrequency).prefix(2))

        #expect(normal[1].timeIntervalSince(normal[0]) < low[1].timeIntervalSince(low[0]))
    }
}
