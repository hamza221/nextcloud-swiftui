// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

#if DEBUG

import SwiftUI

/// One mailbox, so that the previews below differ only in the condition being
/// checked.
private struct MailboxPreview: View {
    struct Message: Identifiable {
        let id = UUID()
        let sender: String
        let subject: String
        let age: TimeInterval
        let unread: Int
    }

    let messages: [Message]
    @State private var selection: Message.ID?

    var body: some View {
        List(selection: $selection) {
            ForEach(messages) { message in
                NCListItem(message.sender, subtitle: message.subject) {
                    NCIcon(.email, label: .decorative)
                } details: {
                    NCListItemDetails(
                        date: .now.addingTimeInterval(-message.age),
                        unreadCount: message.unread
                    )
                }
            }
        }
        .frame(width: 340, height: 220)
    }
}

extension MailboxPreview.Message {
    fileprivate static let inbox: [Self] = [
        .init(sender: "Lorelai Taylor", subject: "About Friday", age: 120, unread: 3),
        .init(sender: "Tom Mörtel", subject: "Re: deployment window", age: 7200, unread: 0),
        .init(sender: "Zaki Cortes", subject: "Photos from the offsite", age: 400_000, unread: 12),
    ]
}

#Preview("ListItem / mailbox", traits: .ncTheme) {
    // Selection is drawn by List, not by NCListItem. Click a row: the highlight,
    // the brand tint and the keyboard arrows are all the system's.
    MailboxPreview(messages: MailboxPreview.Message.inbox)
}

#Preview("ListItem / long content", traits: .ncTheme) {
    List {
        NCListItem(
            "ellena.wright.frederic.conway@a-very-long-instance-name.example.com",
            subtitle: "Re: Re: Fwd: the quarterly planning document that nobody has read yet"
        ) {
            NCIcon(.accountOutline, label: .decorative)
        } details: {
            NCListItemDetails(date: .now.addingTimeInterval(-90), unreadCount: 3456)
        }
    }
    .frame(width: 320, height: 90)
}

#Preview("ListItem / empty", traits: .ncTheme) {
    // A blank subtitle must draw no second line, and a subtitle full of newlines
    // -- which is what a stripped HTML mail body looks like -- must flatten onto
    // one rather than truncating to nothing.
    List {
        NCListItem("No subtitle")
        NCListItem("Blank subtitle", subtitle: "   ")
        NCListItem("Newlines in the subtitle", subtitle: "\n  Hi Lorelai,\n\n  about Friday\n")
    }
    .frame(width: 320, height: 160)
}

#Preview("ListItem / slots", traits: .ncTheme) {
    List {
        NCListItem("Leading only") { NCIcon(.folderOutline, label: .decorative) }
        NCListItem("Leading and trailing", subtitle: "Shared with 3 people") {
            NCIcon(.folder, label: .decorative)
        } trailing: {
            NCIcon(.chevronRight, label: .decorative).foregroundStyle(.tertiary)
        }
        NCListItem("Text only", subtitle: "No slots at all")
    }
    .frame(width: 320, height: 200)
}

#Preview("ListItem / dark", traits: .ncTheme) {
    MailboxPreview(messages: MailboxPreview.Message.inbox)
        .preferredColorScheme(.dark)
}

#Preview("ListItem / increased contrast", traits: .ncIncreasedContrast) {
    // Watch the subtitle's `.secondary` and the row separator. Nothing here
    // paints its own contrast, which is the point.
    MailboxPreview(messages: MailboxPreview.Message.inbox)
}

#Preview("ListItem / RTL", traits: .ncTheme) {
    List {
        NCListItem("لوريلاي تايلور", subtitle: "بخصوص يوم الجمعة") {
            NCIcon(.email, label: .decorative)
        } details: {
            NCListItemDetails(date: .now.addingTimeInterval(-120), unreadCount: 3)
        }
    }
    .frame(width: 320, height: 90)
    .environment(\.layoutDirection, .rightToLeft)
}

#endif
