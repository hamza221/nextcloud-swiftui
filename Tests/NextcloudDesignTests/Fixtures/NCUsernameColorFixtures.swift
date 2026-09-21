// SPDX-FileCopyrightText: 2020-2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

// GENERATED FILE -- do not edit by hand.
//
// Transcribed verbatim from @nextcloud/vue:
//   tests/unit/functions/usernameToColor/__snapshots__/usernameToColor.spec.ts.snap
//
// These vectors are the contract between this package and the web client. If one
// of them fails, the same person is rendering in two different colours depending
// on which Nextcloud client they opened, and the fix is in the Swift port -- not
// in this file.
//
// Regenerate with: Scripts/import-username-color-fixtures.py

internal nonisolated struct NCUsernameColorVector: Sendable {
    let username: String
    let hex: String
}

internal nonisolated enum NCUsernameColorFixtures {
    internal static let all: [NCUsernameColorVector] = [
        NCUsernameColorVector(username: "", hex: "#0082c9"),
        NCUsernameColorVector(username: ",", hex: "#1e78c1"),
        NCUsernameColorVector(username: ".", hex: "#c98879"),
        NCUsernameColorVector(username: "123e4567-e89b-12d3-a456-426614174000", hex: "#bc5c91"),
        NCUsernameColorVector(username: "Akeel Robertson", hex: "#9750a4"),
        NCUsernameColorVector(username: "Alishia Ann Lowry", hex: "#d09e6d"),
        NCUsernameColorVector(username: "Arham Johnson", hex: "#0082c9"),
        NCUsernameColorVector(username: "Brayden Truong", hex: "#d09e6d"),
        NCUsernameColorVector(username: "Daphne Roy", hex: "#9750a4"),
        NCUsernameColorVector(username: "Ellena Wright Frederic Conway", hex: "#c37285"),
        NCUsernameColorVector(username: "Gianluca Hills", hex: "#d6b461"),
        NCUsernameColorVector(username: "Haseeb Stephens", hex: "#d6b461"),
        NCUsernameColorVector(username: "Idris Mac", hex: "#9750a4"),
        NCUsernameColorVector(username: "Kristi Fisher", hex: "#0082c9"),
        NCUsernameColorVector(username: "Lillian Wall", hex: "#bc5c91"),
        NCUsernameColorVector(username: "Lorelai Taylor", hex: "#ddcb55"),
        NCUsernameColorVector(username: "Madina Knight", hex: "#9750a4"),
        NCUsernameColorVector(username: "Meeting", hex: "#c98879"),
        NCUsernameColorVector(username: "Private Circle", hex: "#c37285"),
        NCUsernameColorVector(username: "Rae Hope", hex: "#795aab"),
        NCUsernameColorVector(username: "Santiago Singleton", hex: "#bc5c91"),
        NCUsernameColorVector(username: "Sid Combs", hex: "#d09e6d"),
        NCUsernameColorVector(username: "TestCircle", hex: "#499aa2"),
        NCUsernameColorVector(username: "Tom Mörtel", hex: "#248eb5"),
        NCUsernameColorVector(username: "Vivienne Jacobs", hex: "#1e78c1"),
        NCUsernameColorVector(username: "Zaki Cortes", hex: "#6ea68f"),
        NCUsernameColorVector(username: "a user", hex: "#5b64b3"),
        NCUsernameColorVector(username: "admin", hex: "#d09e6d"),
        NCUsernameColorVector(username: "admin@cloud.example.com", hex: "#9750a4"),
        NCUsernameColorVector(username: "another user", hex: "#ddcb55"),
        NCUsernameColorVector(username: "asd", hex: "#248eb5"),
        NCUsernameColorVector(username: "bar", hex: "#0082c9"),
        NCUsernameColorVector(username: "foo", hex: "#d09e6d"),
        NCUsernameColorVector(username: "wasd", hex: "#b6469d"),
        NCUsernameColorVector(username: "مرحبا بالعالم", hex: "#c98879"),
        NCUsernameColorVector(username: "🙈", hex: "#b6469d"),
    ]
}
