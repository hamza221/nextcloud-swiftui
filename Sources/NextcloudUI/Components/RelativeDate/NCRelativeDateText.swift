// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import Foundation
public import SwiftUI

/// A relative date that keeps itself current.
///
/// ```swift
/// NCRelativeDateText(message.receivedAt, formatter: .init(width: .short, ignoresSeconds: true))
/// ```
///
/// The refresh cadence comes from `NCRelativeDateSchedule`, which relaxes as
/// the date ages. The naive `.periodic(from: .now, by: 1)` would wake every row
/// in a mailbox once a second forever, including the ones showing "last March".
public struct NCRelativeDateText: View {
    private let date: Date
    private let formatter: NCRelativeDateFormatter

    public init(_ date: Date, formatter: NCRelativeDateFormatter = NCRelativeDateFormatter()) {
        self.date = date
        self.formatter = formatter
    }

    public var body: some View {
        TimelineView(NCRelativeDateSchedule(target: date, formatter: formatter)) { context in
            Text(verbatim: formatter.string(for: date, relativeTo: context.date))
        }
    }
}
