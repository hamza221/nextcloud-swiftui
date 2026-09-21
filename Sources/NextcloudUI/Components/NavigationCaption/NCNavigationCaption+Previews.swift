// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

private struct NCNavigationCaptionPreview: View {
    var body: some View {
        List {
            Section {
                NCNavigationItem("Personal", icon: .calendarAccountOutline)
                NCNavigationItem("Team", icon: .calendarAccountOutline, count: 4)
            } header: {
                NCNavigationCaption("Calendars") {
                    Button {
                    } label: {
                        NCIcon(.plus, label: .text("Add calendar"))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(width: 240, height: 160)
    }
}

#Preview("Navigation caption / section header", traits: .ncTheme) {
    NCNavigationCaptionPreview()
}

#Preview("Navigation caption / long content", traits: .ncTheme) {
    NCNavigationCaption("Shared with me by people outside this instance") {
        Button {
        } label: {
            NCIcon(.plus, label: .decorative)
        }
        .buttonStyle(.plain)
    }
    .frame(width: 200)
    .padding()
}

#Preview("Navigation caption / empty", traits: .ncTheme) {
    // No trailing action: the delta over a plain `Text` header is then only the
    // weight and the spacing.
    NCNavigationCaption("Favourites").frame(width: 200).padding()
}

#Preview("Navigation caption / dark", traits: .ncTheme) {
    NCNavigationCaptionPreview().preferredColorScheme(.dark)
}

#Preview("Navigation caption / increased contrast", traits: .ncIncreasedContrast) {
    NCNavigationCaptionPreview()
}

#Preview("Navigation caption / RTL", traits: .ncTheme) {
    NCNavigationCaption("التقويمات") {
        Button {
        } label: {
            NCIcon(.plus, label: .decorative)
        }
        .buttonStyle(.plain)
    }
    .frame(width: 200)
    .padding()
    .environment(\.layoutDirection, .rightToLeft)
}

#endif
