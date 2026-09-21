// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

public import SwiftUI

/// A key combination, in a form that can be both *displayed* and *bound*.
///
/// SwiftUI's `.keyboardShortcut` binds a shortcut but gives no way to render
/// one, and macOS shows shortcuts in help, settings and onboarding constantly.
/// Keeping one value for both means the documented shortcut cannot drift from
/// the bound one.
///
/// The key is stored as a `Character` rather than a `KeyEquivalent` so that the
/// value is reliably `Hashable` -- which it needs to be to sit in a settings
/// model or a dictionary of bindings.
public nonisolated struct NCKeyboardShortcut: Hashable, Sendable {
    /// The key, as the character printed on the key cap.
    public var character: Character
    public var modifiers: EventModifiers

    public init(_ character: Character, modifiers: EventModifiers = .command) {
        self.character = character
        self.modifiers = modifiers
    }

    // Both inits match a literal like "k"; this one steps aside so the
    // Character overload wins and named keys still reach KeyEquivalent.
    @_disfavoredOverload
    public init(_ key: KeyEquivalent, modifiers: EventModifiers = .command) {
        self.init(key.character, modifiers: modifiers)
    }

    /// The value SwiftUI's own shortcut APIs take.
    public var keyEquivalent: KeyEquivalent { KeyEquivalent(character) }

    // `EventModifiers` is an `OptionSet` without a guaranteed `Hashable`
    // conformance, so both are written against its raw value rather than
    // synthesised.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.character == rhs.character && lhs.modifiers.rawValue == rhs.modifiers.rawValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(character)
        hasher.combine(modifiers.rawValue)
    }
}

/// Turning a shortcut into the glyphs macOS shows.
public nonisolated enum NCKeyboardShortcutGlyphs {

    /// The modifier glyphs, in Apple's canonical order.
    ///
    /// Control, Option, Shift, Command -- and it is not negotiable: every menu
    /// and every key cap on the platform uses that order, so any other reads as
    /// a typo.
    public static func modifierGlyphs(_ modifiers: EventModifiers) -> String {
        var glyphs = ""
        if modifiers.contains(.control) { glyphs += "\u{2303}" }
        if modifiers.contains(.option) { glyphs += "\u{2325}" }
        if modifiers.contains(.shift) { glyphs += "\u{21E7}" }
        if modifiers.contains(.command) { glyphs += "\u{2318}" }
        return glyphs
    }

    /// The glyph for a key.
    ///
    /// Named keys get their standard symbol; everything else is upper-cased,
    /// because a key cap reads `K`, never `k`, whether or not Shift is part of
    /// the combination.
    ///
    /// The scalar values are the `NS*FunctionKey` constants that
    /// `KeyEquivalent`'s named cases carry.
    public static func keyGlyph(_ character: Character) -> String {
        switch character {
        case "\r": "\u{21A9}"  // return
        case "\t": "\u{21E5}"  // tab
        case " ": "\u{2423}"  // space
        case "\u{8}", "\u{7F}": "\u{232B}"  // delete: KeyEquivalent carries U+0008
        case "\u{F728}": "\u{2326}"  // forward delete
        case "\u{1B}": "\u{238B}"  // escape
        case "\u{F700}": "\u{2191}"  // up arrow
        case "\u{F701}": "\u{2193}"  // down arrow
        case "\u{F702}": "\u{2190}"  // left arrow
        case "\u{F703}": "\u{2192}"  // right arrow
        case "\u{F729}": "\u{2196}"  // home
        case "\u{F72B}": "\u{2198}"  // end
        case "\u{F72C}": "\u{21DE}"  // page up
        case "\u{F72D}": "\u{21DF}"  // page down
        case "\u{F739}": "\u{2327}"  // clear
        default: String(character).uppercased()
        }
    }

    /// The full rendering, for example `⌘⇧K`.
    public static func string(for shortcut: NCKeyboardShortcut) -> String {
        modifierGlyphs(shortcut.modifiers) + keyGlyph(shortcut.character)
    }

    /// A spoken description, for example "Command Shift K".
    ///
    /// The glyphs are punctuation to a screen reader, so rendering `⌘⇧K` without
    /// this reads as approximately nothing.
    public static func accessibilityDescription(for shortcut: NCKeyboardShortcut) -> String {
        var parts: [String] = []
        if shortcut.modifiers.contains(.control) { parts.append("Control") }
        if shortcut.modifiers.contains(.option) { parts.append("Option") }
        if shortcut.modifiers.contains(.shift) { parts.append("Shift") }
        if shortcut.modifiers.contains(.command) { parts.append("Command") }
        parts.append(keyGlyph(shortcut.character))
        return parts.joined(separator: " ")
    }
}

/// A rendered key combination, as it appears in help and settings.
///
/// ```swift
/// NCKeyboardShortcutLabel(NCKeyboardShortcut("k", modifiers: [.command, .shift]))
/// ```
public struct NCKeyboardShortcutLabel: View {
    private let shortcut: NCKeyboardShortcut

    @Environment(\.ncTheme) private var theme

    public init(_ shortcut: NCKeyboardShortcut) {
        self.shortcut = shortcut
    }

    public var body: some View {
        Text(verbatim: NCKeyboardShortcutGlyphs.string(for: shortcut))
            .font(.body.weight(theme.typography.element))
            .padding(.horizontal, theme.metrics.spacing.tight)
            .padding(.vertical, theme.metrics.spacing.hairline)
            .background(
                RoundedRectangle(cornerRadius: theme.metrics.radius.small)
                    .fill(.quaternary)
            )
            .accessibilityLabel(
                Text(verbatim: NCKeyboardShortcutGlyphs.accessibilityDescription(for: shortcut))
            )
    }
}

extension View {
    /// Binds a shortcut described by ``NCKeyboardShortcut``.
    ///
    /// Using one value to bind and to display is the point: a shortcut shown in
    /// a help sheet that no longer matches the binding is worse than no help
    /// sheet.
    public func ncKeyboardShortcut(_ shortcut: NCKeyboardShortcut) -> some View {
        keyboardShortcut(shortcut.keyEquivalent, modifiers: shortcut.modifiers)
    }
}
