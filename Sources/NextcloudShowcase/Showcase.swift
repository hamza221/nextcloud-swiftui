// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import NextcloudUI
import SwiftUI

/// A live catalogue of the shipped components.
///
/// Run it with `swift run NextcloudShowcase`, or pick the `NextcloudShowcase`
/// scheme after opening the package in Xcode.
///
/// ponytail: one file, an inline `@State` knob per control. The roadmap's
/// three-target version with shared knob infrastructure and a notarized DMG is
/// worth building once there are enough demos to share something between; at
/// seven components there is nothing to share yet. Revisit at ~40 demos, as the
/// roadmap says.
@main
struct NextcloudShowcaseApp: App {
    var body: some Scene {
        WindowGroup("Nextcloud UI showcase") {
            ShowcaseWindow()
        }
        .defaultSize(width: 940, height: 640)
    }
}

// MARK: - Window

private struct ShowcaseWindow: View {
    @State private var demo: Demo? = .chip
    @State private var brandHex = "#0082C9"
    @State private var appearance: Appearance = .system

    /// Invalid hex keeps the last good theme rather than blanking the window
    /// while someone is halfway through typing one.
    private var theme: NCTheme {
        guard let brand = NCBrand(primaryHex: brandHex) else { return .nextcloud }
        return NCTheme(brand: brand)
    }

    var body: some View {
        NavigationSplitView {
            List(Demo.allCases, selection: $demo) { demo in
                Text(demo.title)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 260)
        } detail: {
            ScrollView {
                detail
                    .padding(theme.metrics.spacing.loose)
            }
            .navigationTitle(demo?.title ?? "Showcase")
        }
        .toolbar {
            ToolbarItem {
                TextField("Brand", text: $brandHex)
                    .frame(width: 96)
                    .help("Instance brand colour as #RRGGBB")
            }
            ToolbarItem {
                Picker("Appearance", selection: $appearance) {
                    ForEach(Appearance.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
        }
        .ncTheme(theme)
        .preferredColorScheme(appearance.colorScheme)
    }

    @ViewBuilder private var detail: some View {
        switch demo {
        case .chip: ChipDemo()
        case .counterBubble: CounterBubbleDemo()
        case .noteCard: NoteCardDemo()
        case .userStatus: UserStatusDemo()
        case .highlight: HighlightDemo()
        case .keyboardShortcut: KeyboardShortcutDemo()
        case .relativeDate: RelativeDateDemo()
        case .avatar: AvatarDemo()
        case .userBubble: UserBubbleDemo()
        case .profileCard: ProfileCardDemo()
        case .listItem: ListItemDemo()
        case .navigationItem: NavigationItemDemo()
        case .breadcrumbs: BreadcrumbsDemo()
        case .mailScreen: MailScreenDemo()
        case .tokens: TokenDemo()
        case nil: Text("Pick a component.")
        }
    }
}

private enum Demo: String, CaseIterable, Identifiable {
    case chip
    case counterBubble
    case noteCard
    case userStatus
    case highlight
    case keyboardShortcut
    case relativeDate
    case avatar
    case userBubble
    case profileCard
    case listItem
    case navigationItem
    case breadcrumbs
    case mailScreen
    case tokens

    var id: Self { self }

    var title: String {
        switch self {
        case .chip: "Chip"
        case .counterBubble: "Counter bubble"
        case .noteCard: "Note card"
        case .userStatus: "User status badge"
        case .highlight: "Search highlight"
        case .keyboardShortcut: "Keyboard shortcut"
        case .relativeDate: "Relative date"
        case .avatar: "Avatar"
        case .userBubble: "User bubble"
        case .profileCard: "Profile card"
        case .listItem: "List item"
        case .navigationItem: "Navigation item"
        case .breadcrumbs: "Breadcrumbs"
        case .mailScreen: "Mail screen"
        case .tokens: "Colour tokens"
        }
    }
}

private enum Appearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

// MARK: - Stage

/// The component on a neutral backdrop, its knobs underneath.
private struct Stage<Preview: View, Controls: View>: View {
    @Environment(\.ncTheme) private var theme

    private let preview: Preview
    private let controls: Controls

    init(@ViewBuilder preview: () -> Preview, @ViewBuilder controls: () -> Controls) {
        self.preview = preview()
        self.controls = controls()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.spacing.loose) {
            preview
                .frame(maxWidth: .infinity, minHeight: 140)
                .background(.quinary, in: RoundedRectangle(cornerRadius: theme.metrics.radius.container))
            Form { controls }
                .formStyle(.grouped)
                .frame(maxHeight: 320)
        }
    }
}

// MARK: - Demos

private struct ChipDemo: View {
    @State private var text = "Nextcloud"
    // `Role` is nested in a generic, so its type changes with the leading view.
    // One `NCChip` spelling with an optional icon keeps a single `Role` type here.
    @State private var role = NCChip<NCIcon?>.Role.neutral
    @State private var removable = true
    @State private var leadingIcon = false

    var body: some View {
        Stage {
            NCChip(text, role: role, onRemove: removable ? {} : nil) {
                if leadingIcon {
                    NCIcon(.accountOutline, label: .decorative, size: .small)
                }
            }
        } controls: {
            TextField("Text", text: $text)
            Picker("Role", selection: $role) {
                ForEach(Array(NCChip<NCIcon?>.Role.allCases), id: \.self) { Text(String(describing: $0)) }
            }
            Toggle("Removable", isOn: $removable)
            Toggle("Leading icon", isOn: $leadingIcon)
        }
    }
}

private struct CounterBubbleDemo: View {
    @State private var count = 7
    @State private var limit = NCCounterFormat.defaultLimit
    @State private var role = NCCounterBubble.Role.neutral

    var body: some View {
        Stage {
            NCCounterBubble(count: count, role: role, limit: limit)
        } controls: {
            Stepper("Count: \(count)", value: $count, in: 0...500)
            Stepper("Limit: \(limit)", value: $limit, in: 1...500)
            Picker("Role", selection: $role) {
                ForEach(Array(NCCounterBubble.Role.allCases), id: \.self) { Text(String(describing: $0)) }
            }
        }
    }
}

private struct NoteCardDemo: View {
    @State private var role = NCNoteCard<Text>.Role.info
    @State private var title = "Shared link"
    @State private var message = "Anyone with this link can view the folder."

    var body: some View {
        Stage {
            NCNoteCard(role, title: title.isEmpty ? nil : LocalizedStringResource(stringLiteral: title)) {
                Text(verbatim: message)
            }
            .padding(.horizontal, 24)
        } controls: {
            Picker("Role", selection: $role) {
                ForEach(Array(NCNoteCard<Text>.Role.allCases), id: \.self) { Text(String(describing: $0)) }
            }
            TextField("Title", text: $title)
            TextField("Message", text: $message, axis: .vertical)
        }
    }
}

private struct UserStatusDemo: View {
    @State private var status = NCUserStatus.online

    var body: some View {
        Stage {
            NCUserStatusBadge(status)
                .scaleEffect(4)
        } controls: {
            Picker("Status", selection: $status) {
                ForEach(Array(NCUserStatus.allCases), id: \.self) { Text(String(describing: $0)) }
            }
            .pickerStyle(.inline)
        }
    }
}

private struct HighlightDemo: View {
    @State private var text = "Quarterly report, final version (2).odt"
    @State private var query = "report"

    var body: some View {
        Stage {
            NCHighlightText(text, matching: query)
                .font(.title3)
        } controls: {
            TextField("Text", text: $text)
            TextField("Query", text: $query)
            LabeledContent("Matches", value: "\(NCHighlight.ranges(in: text, matching: query).count)")
        }
    }
}

private struct KeyboardShortcutDemo: View {
    @State private var key = "K"
    @State private var modifiers = EventModifiers.command

    var body: some View {
        Stage {
            NCKeyboardShortcutLabel(NCKeyboardShortcut(key.first ?? "K", modifiers: modifiers))
                .font(.title2)
        } controls: {
            TextField("Key", text: $key)
            Toggle("Command", isOn: binding(for: .command))
            Toggle("Shift", isOn: binding(for: .shift))
            Toggle("Option", isOn: binding(for: .option))
            Toggle("Control", isOn: binding(for: .control))
        }
    }

    private func binding(for modifier: EventModifiers) -> Binding<Bool> {
        Binding(
            get: { modifiers.contains(modifier) },
            set: { on in
                if on {
                    modifiers.formUnion(modifier)
                } else {
                    modifiers.subtract(modifier)
                }
            }
        )
    }
}

private struct RelativeDateDemo: View {
    /// A decimal exponent: the interesting boundaries (a minute, an hour, a day)
    /// are decades apart, and a linear slider spends all its travel past the last
    /// one.
    @State private var ageExponent = 2.0
    @State private var width = NCRelativeDateFormatter.Width.long
    @State private var ignoresSeconds = false

    private var secondsAgo: TimeInterval { pow(10, ageExponent) }

    var body: some View {
        Stage {
            NCRelativeDateText(
                Date(timeIntervalSinceNow: -secondsAgo),
                formatter: NCRelativeDateFormatter(width: width, ignoresSeconds: ignoresSeconds)
            )
            .font(.title2)
        } controls: {
            Slider(value: $ageExponent, in: 0...7.5) {
                Text(verbatim: "Age")
            }
            LabeledContent(
                "Age",
                value: Duration.seconds(secondsAgo).formatted(
                    .units(allowed: [.days, .hours, .minutes, .seconds], maximumUnitCount: 2)
                )
            )
            Picker("Width", selection: $width) {
                ForEach(Array(NCRelativeDateFormatter.Width.allCases), id: \.self) { Text(String(describing: $0)) }
            }
            Toggle("Ignores seconds", isOn: $ignoresSeconds)
        }
    }
}

private struct TokenDemo: View {
    @Environment(\.ncTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.spacing.comfortable) {
            swatches(
                "Primary",
                [
                    ("primary", theme.colors.primary),
                    ("primaryHover", theme.colors.primaryHover),
                    ("primarySurface", theme.colors.primarySurface),
                    ("onPrimary", theme.colors.onPrimary),
                ])
            swatches(
                "Status",
                [
                    ("info", theme.colors.info.element),
                    ("success", theme.colors.success.element),
                    ("warning", theme.colors.warning.element),
                    ("error", theme.colors.error.element),
                ])
            swatches(
                "Accents",
                [
                    ("favorite", theme.colors.favorite),
                    ("highlight", theme.colors.highlight),
                    ("online", theme.colors.userStatus.online),
                    ("away", theme.colors.userStatus.away),
                ])
        }
    }

    private func swatches(_ title: String, _ colors: [(String, NCDynamicColor)]) -> some View {
        VStack(alignment: .leading, spacing: theme.metrics.spacing.standard) {
            Text(verbatim: title)
                .font(.headline.weight(theme.typography.heading))
            HStack(spacing: theme.metrics.spacing.standard) {
                ForEach(colors, id: \.0) { name, color in
                    VStack(spacing: theme.metrics.spacing.tight) {
                        RoundedRectangle(cornerRadius: theme.metrics.radius.element)
                            .fill(color)
                            .frame(width: 88, height: 56)
                        Text(verbatim: name)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

// MARK: - Wave 2 demos

private struct AvatarDemo: View {
    @State private var displayName = "Lorelai Taylor"
    @State private var user = "lorelai"
    @State private var size = NCAvatar.Size.large
    @State private var showsStatus = true
    @State private var status = NCUserStatus.online

    var body: some View {
        Stage {
            NCAvatar(
                displayName: displayName,
                user: user.isEmpty ? nil : user,
                size: size,
                status: showsStatus ? status : nil
            )
        } controls: {
            TextField("Display name", text: $displayName)
            TextField("User id", text: $user)
                .help("The colour is hashed from this, falling back to the display name.")
            Picker("Size", selection: $size) {
                ForEach(Array(NCAvatar.Size.allCases), id: \.self) { Text(String(describing: $0)) }
            }
            Toggle("Presence", isOn: $showsStatus)
            Picker("Status", selection: $status) {
                ForEach(Array(NCUserStatus.allCases), id: \.self) { Text(String(describing: $0)) }
            }
            .disabled(!showsStatus)
        }
    }
}

private struct UserBubbleDemo: View {
    @State private var displayName = "Rory Gilmore"
    @State private var size = NCAvatar.Size.small
    @State private var tappable = true

    var body: some View {
        Stage {
            NCUserBubble(
                displayName: displayName,
                user: "rory",
                size: size,
                action: tappable ? {} : nil
            )
        } controls: {
            TextField("Display name", text: $displayName)
            Picker("Size", selection: $size) {
                ForEach(Array(NCAvatar.Size.allCases), id: \.self) { Text(String(describing: $0)) }
            }
            Toggle("Tappable", isOn: $tappable)
        }
    }
}

private struct ProfileCardDemo: View {
    @State private var displayName = "Luke Danes"
    @State private var role = "Operations"
    @State private var email = "luke@example.org"
    @State private var status = NCUserStatus.away

    var body: some View {
        Stage {
            NCProfileCard(
                displayName: displayName,
                user: "luke",
                status: status,
                secondaryLines: [role, email].filter { !$0.isEmpty }
            ) {
                Button("Message") {}
            }
        } controls: {
            TextField("Display name", text: $displayName)
            TextField("Role", text: $role)
            TextField("Email", text: $email)
            Picker("Status", selection: $status) {
                ForEach(Array(NCUserStatus.allCases), id: \.self) { Text(String(describing: $0)) }
            }
        }
    }
}

// MARK: - Wave 3 demos

private struct ListItemDemo: View {
    @State private var title = "Sookie St. James"
    @State private var subtitle = "Re: the Dragonfly opening menu"
    @State private var unread = 3
    @State private var showsAvatar = true

    var body: some View {
        Stage {
            List {
                NCListItem(title, subtitle: subtitle.isEmpty ? nil : subtitle) {
                    if showsAvatar {
                        NCAvatar(displayName: title, user: "sookie")
                    }
                } details: {
                    NCListItemDetails(date: .now.addingTimeInterval(-125), unreadCount: unread)
                }
            }
            .frame(height: 120)
        } controls: {
            TextField("Title", text: $title)
            TextField("Subtitle", text: $subtitle)
            Stepper("Unread: \(unread)", value: $unread, in: 0...500)
            Toggle("Leading avatar", isOn: $showsAvatar)
        }
    }
}

// MARK: - Wave 4 demos

private struct NavigationItemDemo: View {
    @State private var title = "Inbox"
    @State private var count = 12
    @State private var showsActions = true

    var body: some View {
        Stage {
            List {
                NCNavigationCaption("Mailboxes")
                if showsActions {
                    NCNavigationItem(title, icon: .folderOutline, count: count) {
                        Button("Mark all as read") {}
                        Button("Rename") {}
                    }
                } else {
                    NCNavigationItem(title, icon: .folderOutline, count: count)
                }
            }
            .frame(height: 120)
        } controls: {
            TextField("Title", text: $title)
            Stepper("Count: \(count)", value: $count, in: 0...500)
            Toggle("Trailing actions", isOn: $showsActions)
        }
    }
}

private struct BreadcrumbsDemo: View {
    @State private var path = "Home/Projects/Nextcloud/Design/Icons/Exports"
    @State private var width = 420.0

    private var segments: [NCBreadcrumbSegment] {
        path.split(separator: "/").map { NCBreadcrumbSegment(id: String($0), title: String($0)) }
    }

    var body: some View {
        Stage {
            NCBreadcrumbs(segments) { _ in }
                .frame(width: width)
        } controls: {
            TextField("Path", text: $path)
            Slider(value: $width, in: 120...640) { Text(verbatim: "Width") }
            LabeledContent("Width", value: "\(Int(width)) pt")
                .help("Narrow the bar to watch the middle segments collapse into a menu.")
        }
    }
}

// MARK: - The real test

/// One Mail screen built from the library, which `docs/ROADMAP.md` calls the
/// real test: it exercises `NCNavigationItem`, `NCCounterBubble`, `NCListItem`,
/// `NCAvatar` and `NCUserBubble` together, which is where API problems show up
/// that no unit test finds.
///
/// ponytail: two `List`s side by side rather than a `NavigationSplitView`. The
/// showcase is already inside one, and nesting them buys nothing this screen is
/// meant to check. Build it as a real split view in the scratch Mail app.
private struct MailScreenDemo: View {
    @Environment(\.ncTheme) private var theme

    @State private var mailbox: String? = "Inbox"
    @State private var selected: Message.ID?

    private struct Message: Identifiable {
        let id: String
        let sender: String
        let user: String
        let subject: String
        let preview: String
        let age: TimeInterval
        let unread: Bool
    }

    private let messages = [
        Message(
            id: "1", sender: "Sookie St. James", user: "sookie",
            subject: "The Dragonfly opening menu",
            preview: "I moved the risotto to the second course, tell me what you think.",
            age: 125, unread: true),
        Message(
            id: "2", sender: "Michel Gerard", user: "michel",
            subject: "Front desk rota",
            preview: "I am not working Sundays. This is not a negotiation.",
            age: 4_200, unread: true),
        Message(
            id: "3", sender: "Luke Danes", user: "luke",
            subject: "Re: coffee order",
            preview: "Fine. But this is the last time I deliver it.",
            age: 90_000, unread: false),
    ]

    private var selectedMessage: Message? {
        messages.first { $0.id == selected } ?? messages.first
    }

    var body: some View {
        HStack(spacing: 0) {
            List(selection: $mailbox) {
                NCNavigationCaption("Mailboxes")
                ForEach(["Inbox", "Sent", "Drafts", "Archive"], id: \.self) { name in
                    NCNavigationItem(name, icon: .folderOutline, count: name == "Inbox" ? 2 : 0)
                        .tag(name)
                }
            }
            .frame(width: 180)

            Divider()

            List(messages, selection: $selected) { message in
                NCListItem(message.sender, subtitle: message.subject) {
                    NCAvatar(displayName: message.sender, user: message.user)
                } details: {
                    NCListItemDetails(
                        date: .now.addingTimeInterval(-message.age),
                        unreadCount: message.unread ? 1 : 0
                    )
                }
                .fontWeight(message.unread ? .semibold : nil)
                .tag(message.id)
            }
            .frame(width: 280)

            Divider()

            if let message = selectedMessage {
                VStack(alignment: .leading, spacing: theme.metrics.spacing.comfortable) {
                    Text(verbatim: message.subject)
                        .font(.title2.weight(theme.typography.heading))
                    NCUserBubble(displayName: message.sender, user: message.user, size: .medium)
                    Text(verbatim: message.preview)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(theme.metrics.spacing.loose)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: 380)
        .background(.quinary, in: RoundedRectangle(cornerRadius: theme.metrics.radius.container))
        .onChange(of: mailbox) { selected = nil }
    }
}
