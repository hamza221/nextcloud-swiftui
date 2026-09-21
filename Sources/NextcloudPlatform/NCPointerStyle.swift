// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// The cursor shown while the pointer is over a view.
///
/// A pointer cue is an *enhancement*: every interaction it decorates must also
/// work without a pointer, because iOS may have none. Nothing in this package
/// should depend on hover to be usable.
public enum NCPointerStyle: Hashable, Sendable, CaseIterable {
    /// Something that navigates or opens.
    case link
    /// Text that can be selected.
    case text
    /// A horizontally draggable divider, such as a sidebar edge.
    case columnResize
    /// A grabbable item at rest.
    case grabIdle
    /// A grabbable item mid-drag.
    case grabActive
}

extension View {
    /// Applies a pointer style where the platform has a pointer.
    ///
    /// A no-op where it does not, rather than a compile error at every call
    /// site.
    public func ncPointerStyle(_ style: NCPointerStyle) -> some View {
        modifier(NCPointerStyleModifier(style: style))
    }
}

private struct NCPointerStyleModifier: ViewModifier {
    let style: NCPointerStyle

    func body(content: Content) -> some View {
        #if canImport(AppKit)
            content.pointerStyle(style.resolved)
        #else
            content
        #endif
    }
}

#if canImport(AppKit)
    extension NCPointerStyle {
        fileprivate var resolved: PointerStyle {
            switch self {
            case .link: .link
            case .text: .horizontalText
            case .columnResize: .columnResize
            case .grabIdle: .grabIdle
            case .grabActive: .grabActive
            }
        }
    }
#endif
