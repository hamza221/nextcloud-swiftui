// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// The two font weights the design system specifies.
///
/// Face, size and line height are all absent on purpose: they come from Dynamic
/// Type. The web's `--default-font-size: 15px` is a browser workaround, not a
/// design intent, and hard-coding it would break text scaling and accessibility
/// sizes for every consumer.
///
/// Use these to weight a *semantic* font, never to build one from scratch:
///
/// ```swift
/// Text(title).font(.headline.weight(theme.typography.heading))
/// ```
public nonisolated struct NCTypography: Hashable, Sendable {
    /// For interactive elements: buttons, chips, navigation rows.
    /// `--font-weight-element: 500`.
    public var element: Font.Weight
    /// For titles and headings. `--font-weight-heading: 600`.
    public var heading: Font.Weight

    public init(element: Font.Weight = .medium, heading: Font.Weight = .semibold) {
        self.element = element
        self.heading = heading
    }

    public static let nextcloud = NCTypography()
}
