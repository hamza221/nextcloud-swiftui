// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

internal import Foundation

#if canImport(AppKit)
    internal import AppKit
#elseif canImport(UIKit)
    internal import UIKit
#endif

/// Opening a URL from outside a view.
///
/// - Important: Inside a view, use `@Environment(\.openURL)` instead. It is
///   cross-platform already, and it respects an app's `handlesExternalEvents`
///   and `openURL` overrides, which this does not. This exists for the cases
///   with no environment to read -- a menu command handler, a model object.
public enum NCOpenURL {

    /// Opens a URL with the system handler.
    ///
    /// - Returns: Whether a handler accepted it. On platforms that answer
    ///   asynchronously this reports only that the request was made.
    @discardableResult
    public static func open(_ url: URL) -> Bool {
        #if canImport(AppKit)
            return NSWorkspace.shared.open(url)
        #elseif canImport(UIKit)
            UIApplication.shared.open(url)
            return true
        #else
            return false
        #endif
    }
}
