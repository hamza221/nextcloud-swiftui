// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// Animation durations.
///
/// Two, matching `--animation-quick` and `--animation-slow`. Everything else a
/// component might animate should use a system default, which already responds
/// to Reduce Motion.
///
/// - Note: The styleguide's dark theme sets `--animation-slow` to 300ms where
///   the light theme sets 200ms. That is a slip in the mock rather than a design
///   decision -- an appearance change must not change timing -- so 200ms is used
///   for both.
public nonisolated struct NCMotion: Hashable, Sendable {
    public var quick: Duration
    public var slow: Duration

    public init(quick: Duration = .milliseconds(100), slow: Duration = .milliseconds(200)) {
        self.quick = quick
        self.slow = slow
    }

    /// A quick ease-out, for state that should feel immediate.
    public var quickAnimation: Animation { .easeOut(duration: quick.seconds) }
    /// A slower ease-in-out, for content that moves.
    public var slowAnimation: Animation { .easeInOut(duration: slow.seconds) }

    public static let nextcloud = NCMotion()
}
