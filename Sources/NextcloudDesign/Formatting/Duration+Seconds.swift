// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

nonisolated extension Duration {
    /// The duration in seconds, for the SwiftUI and Foundation APIs that predate
    /// `Duration`.
    internal var seconds: Double {
        let (whole, attoseconds) = components
        return Double(whole) + Double(attoseconds) * 1e-18
    }
}
