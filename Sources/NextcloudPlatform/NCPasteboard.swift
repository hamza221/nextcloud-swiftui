// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

internal import Foundation

#if canImport(AppKit)
    internal import AppKit
#elseif canImport(UIKit)
    internal import UIKit
#endif

/// Copying text to the system pasteboard.
///
/// SwiftUI's own copy affordances are tied to `.copyable` and a focused view,
/// which does not cover "copy this address" on a context menu item.
public enum NCPasteboard {

    /// Replaces the pasteboard contents with a plain string.
    public static func copy(_ string: String) {
        #if canImport(AppKit)
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(string, forType: .string)
        #elseif canImport(UIKit)
            UIPasteboard.general.string = string
        #endif
    }

    /// The plain string currently on the pasteboard, if there is one.
    public static func string() -> String? {
        #if canImport(AppKit)
            return NSPasteboard.general.string(forType: .string)
        #elseif canImport(UIKit)
            return UIPasteboard.general.string
        #else
            return nil
        #endif
    }
}
