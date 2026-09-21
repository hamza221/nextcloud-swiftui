// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

/// The rows in the context they are designed for, so that selection, the hover
/// highlight and the focus ring come from `List` rather than from the component.
private struct NCNavigationItemPreview: View {
    @State private var selection: String? = "inbox"

    var body: some View {
        List(selection: $selection) {
            Section {
                NCNavigationItem("Inbox", icon: .email, count: 12) {
                    Button {
                    } label: {
                        Text(verbatim: "Mark all as read")
                    }
                    Button {
                    } label: {
                        Text(verbatim: "Rename")
                    }
                }
                .tag("inbox")
                NCNavigationItem("Drafts", icon: .pencilOutline, count: 2).tag("drafts")
                NCNavigationItem("Sent", icon: .shareVariantOutline).tag("sent")
                DisclosureGroup {
                    NCNavigationItem("Invoices", icon: .folderOutline, count: 3).tag("invoices")
                    NCNavigationItem("Receipts", icon: .folderOutline).tag("receipts")
                } label: {
                    // Nesting is `DisclosureGroup`'s job, not the row's.
                    NCNavigationItem("Archive", icon: .folderOutline)
                }
            } header: {
                NCNavigationCaption("Mailboxes")
            }
        }
        .frame(width: 260, height: 300)
    }
}

#Preview("Navigation item / sidebar", traits: .ncTheme) {
    NCNavigationItemPreview()
}

#Preview("Navigation item / long content", traits: .ncTheme) {
    List {
        NCNavigationItem(
            "Quarterly reporting and reconciliation, archived",
            icon: .folderOutline,
            count: 2048
        ) {
            Button {
            } label: {
                Text(verbatim: "Rename")
            }
        }
    }
    .frame(width: 220, height: 80)
}

#Preview("Navigation item / empty", traits: .ncTheme) {
    // No icon, no count, no actions: the floor of the component.
    List {
        NCNavigationItem("All accounts")
    }
    .frame(width: 220, height: 80)
}

#Preview("Navigation item / dark", traits: .ncTheme) {
    NCNavigationItemPreview().preferredColorScheme(.dark)
}

// `\.colorSchemeContrast` is get-only, so a preview cannot switch the system
// setting on. What it can do is drive the tokens to a high-contrast brand, which
// is the half of the result this library owns; the system half is the canvas's
// own contrast variant.
#Preview(
    "Navigation item / increased contrast",
    traits: .ncTheme(brand: NCBrand(primaryHex: "#00263f") ?? .nextcloud)
) {
    NCNavigationItemPreview()
}

#Preview("Navigation item / RTL", traits: .ncTheme) {
    List {
        NCNavigationItem("البريد الوارد", icon: .email, count: 12) {
            Button {
            } label: {
                Text(verbatim: "إعادة تسمية")
            }
        }
        NCNavigationItem("المسودات", icon: .pencilOutline, count: 2)
    }
    .frame(width: 220, height: 120)
    .environment(\.layoutDirection, .rightToLeft)
}

#endif
