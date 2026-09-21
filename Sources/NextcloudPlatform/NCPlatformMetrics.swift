// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// What the current platform can do, and at what size.
///
/// This exists so that a component asks a question about *capability* rather
/// than branching on a platform name. `NCListItem` asking
/// ``pointerIsPrimaryInput`` keeps working when iOS is added; the same component
/// written around `#if os(macOS)` does not.
public enum NCPlatformMetrics {

    /// Whether a pointer is the expected primary input.
    ///
    /// When `false`, hit targets grow and hover-only affordances must have a
    /// visible equivalent.
    public static var pointerIsPrimaryInput: Bool {
        #if canImport(AppKit)
        true
        #else
        false
        #endif
    }

    /// The minimum comfortable hit target.
    ///
    /// macOS and iOS genuinely differ here, and this is the number the web
    /// library's 34px `--default-clickable-area` was trying to be. Neither
    /// platform wants 34.
    public static var minimumHitTarget: CGFloat {
        #if canImport(AppKit)
        20
        #else
        44
        #endif
    }

    /// The standard leading inset of a list row's content.
    public static var listRowInset: CGFloat {
        #if canImport(AppKit)
        8
        #else
        16
        #endif
    }
}
