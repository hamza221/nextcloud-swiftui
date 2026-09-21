// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

/// # The platform layer
///
/// This is the only target permitted to import AppKit, UIKit or Cocoa, and the
/// only one permitted to branch on `#if canImport(AppKit)`. Both rules are
/// enforced by `Scripts/check-platform-discipline.sh` as a hard CI failure, so
/// that "no AppKit outside an isolated layer" is a build error rather than
/// something a reviewer has to notice.
///
/// Every abstraction here presents a SwiftUI-typed surface: nothing that crosses
/// this boundary may mention an `NS*` or `UI*` type, which is separately linted.
///
/// There are deliberately few of these. The list is:
///
/// - ``NCImageDecoder`` -- bytes to a SwiftUI `Image`
/// - ``NCPasteboard`` -- copying text
/// - ``NCPointerStyle`` -- hover cursors
/// - ``NCPlatformMetrics`` -- what the platform can and cannot do
/// - ``NCOpenURL`` -- opening a URL outside a view
///
/// and later `NCTextViewBridge`, which arrives with `NCRichContenteditable` in
/// v1.1. A seventh abstraction is a design review, not a pull request: each one
/// added here is a place iOS support can diverge.
public enum NCPlatform {
    /// The platform this build is targeting, for diagnostics and for the
    /// showcase's about box.
    public static var name: String {
        #if canImport(AppKit)
        "macOS"
        #elseif canImport(UIKit)
        "iOS"
        #else
        "unknown"
        #endif
    }
}
