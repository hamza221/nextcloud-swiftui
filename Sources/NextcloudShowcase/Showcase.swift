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
