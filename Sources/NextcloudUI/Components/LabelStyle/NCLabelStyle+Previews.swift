// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

/// A label built the way a caller does: an ``NCIcon`` in the icon slot and
/// caller text in the title slot.
private struct NCLabelStyleSample: View {
    let title: String
    let symbol: NCSymbol

    var body: some View {
        Label {
            Text(verbatim: title)
        } icon: {
            NCIcon(symbol, label: .decorative)
        }
    }
}

#Preview("LabelStyle / standard", traits: .ncTheme) {
    VStack(alignment: .leading, spacing: 8) {
        NCLabelStyleSample(title: "Inbox", symbol: .email)
        NCLabelStyleSample(title: "Shared with you", symbol: .accountMultiple)
        NCLabelStyleSample(title: "Favourites", symbol: .star)
    }
    .labelStyle(.nc)
    .padding()
}

#Preview("LabelStyle / icon only", traits: .ncTheme) {
    // Nothing visible but glyphs, and every one still has a spoken name: the
    // system style keeps the title for assistive technology. Inspect this one
    // with the accessibility inspector rather than by eye.
    HStack(spacing: 8) {
        NCLabelStyleSample(title: "Archive", symbol: .folderOutline)
        NCLabelStyleSample(title: "Delete", symbol: .deleteOutline)
        NCLabelStyleSample(title: "Share", symbol: .shareVariant)
    }
    .labelStyle(.ncIconOnly)
    .padding()
}

#Preview("LabelStyle / long content", traits: .ncTheme) {
    NCLabelStyleSample(
        title: "Quarterly planning, archived correspondence and everything else",
        symbol: .folderOutline
    )
    .labelStyle(.nc)
    .frame(width: 200)
    .padding()
}

#Preview("LabelStyle / empty", traits: .ncTheme) {
    // An empty title keeps the gap but draws nothing after it. An icon-only
    // label with an empty title has no spoken name at all, which is what the
    // accessibility inspector should show as a warning.
    VStack(alignment: .leading, spacing: 8) {
        NCLabelStyleSample(title: "", symbol: .email).labelStyle(.nc)
        NCLabelStyleSample(title: "", symbol: .email).labelStyle(.ncIconOnly)
    }
    .padding()
}

#Preview("LabelStyle / dark", traits: .ncTheme) {
    VStack(alignment: .leading, spacing: 8) {
        NCLabelStyleSample(title: "Inbox", symbol: .email)
        NCLabelStyleSample(title: "Drafts", symbol: .pencilOutline)
    }
    .labelStyle(.nc)
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("LabelStyle / increased contrast", traits: .ncTheme) {
    // `\.colorSchemeContrast` is read-only, so Increase Contrast cannot be
    // forced from preview code -- toggle it in the canvas accessibility
    // controls. Neither layout picks a colour, so both follow whatever
    // foreground style is in effect.
    VStack(alignment: .leading, spacing: 8) {
        NCLabelStyleSample(title: "Inbox", symbol: .email)
        NCLabelStyleSample(title: "Secondary", symbol: .email).foregroundStyle(.secondary)
    }
    .labelStyle(.nc)
    .padding()
}

#Preview("LabelStyle / RTL", traits: .ncTheme) {
    // The icon moves to the trailing edge with the layout. `HStack` does that;
    // nothing here reads the layout direction.
    VStack(alignment: .leading, spacing: 8) {
        NCLabelStyleSample(title: "البريد الوارد", symbol: .email)
        NCLabelStyleSample(title: "المفضلة", symbol: .star)
    }
    .labelStyle(.nc)
    .environment(\.layoutDirection, .rightToLeft)
    .padding()
}

#Preview("LabelStyle / in a toolbar button", traits: .ncTheme) {
    // The pairing this style exists for: an icon button whose title is invisible
    // and audible.
    HStack(spacing: 8) {
        Button(action: {}) { NCLabelStyleSample(title: "Archive", symbol: .folderOutline) }
        Button(action: {}) { NCLabelStyleSample(title: "Delete", symbol: .deleteOutline) }
    }
    .labelStyle(.ncIconOnly)
    .buttonStyle(.icon)
    .padding()
}

#endif
