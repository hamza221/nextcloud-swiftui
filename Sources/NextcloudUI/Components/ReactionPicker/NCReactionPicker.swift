// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import NextcloudPlatform
public import SwiftUI

/// Talk's reaction row: the emoji already on a message, plus a way to add one.
///
/// ```swift
/// NCReactionPicker(summary) { emoji in
///     Task { try await client.react(to: message.id, with: emoji) }
/// }
/// ```
///
/// Each pill is an ``NCChip`` in a `Button`. Tapping one adds this account's
/// reaction or takes it away, and a pill this account is part of carries the
/// `isSelected` trait, so VoiceOver says "selected" rather than leaving the
/// state to a tint nobody can hear.
///
/// ## The emoji picker is the system's
///
/// macOS ships one, with search, skin tones, recents and every Unicode
/// category, and `⌃⌘Space` opens it everywhere else on the machine. A grid of
/// our own would be a worse copy that goes stale each Unicode release, so the
/// overflow menu opens the `NCEmojiPalette` shim in `NextcloudPlatform` instead.
///
/// The palette *inserts* into the focused responder rather than returning a
/// value, so this view builds a one-character field to catch what it inserts.
/// The field exists only while the palette is open, so a keyboard user tabbing
/// through a message never lands on it. That is the whole of the
/// platform-specific code here.
///
/// ## Counts are not in here
///
/// Toggling, the zero case and the ordering live in ``NCReactionSummary``,
/// which has no SwiftUI in it. What is left in `body` is composition.
public struct NCReactionPicker: View {
    private let summary: NCReactionSummary
    private let frequent: [String]
    private let visibleLimit: Int
    private let onToggle: (String) -> Void

    @State private var paletteEntry = ""
    @State private var catchingPaletteInsertion = false
    @FocusState private var paletteEntryFocused: Bool
    @Environment(\.ncTheme) private var theme

    /// The reactions Talk offers first.
    ///
    /// Not localised and not themed: an emoji means the same thing in every
    /// language, and this list matches what the web client shows so that the
    /// same six are in the same place in both.
    public static let defaultFrequent = ["👍", "👎", "😀", "🎉", "❤️", "🚀"]

    /// Creates a reaction row.
    ///
    /// - Parameters:
    ///   - summary: What is already on the message.
    ///   - frequent: The emoji the overflow menu offers directly. Defaults to
    ///     ``defaultFrequent``.
    ///   - visibleLimit: How many pills sit in the row before the rest move into
    ///     the overflow menu.
    ///   - onToggle: Called with the emoji. The caller sends it to the server
    ///     and hands back a new ``NCReactionSummary``; this view holds no state
    ///     of its own, so an optimistic update and a rollback both belong to the
    ///     caller.
    public init(
        _ summary: NCReactionSummary,
        frequent: [String] = defaultFrequent,
        visibleLimit: Int = 6,
        onToggle: @escaping (String) -> Void
    ) {
        self.summary = summary
        self.frequent = frequent
        self.visibleLimit = visibleLimit
        self.onToggle = onToggle
    }

    public var body: some View {
        let split = summary.split(visible: visibleLimit)
        HStack(spacing: theme.metrics.spacing.tight) {
            ForEach(split.visible) { pill($0) }
            overflowMenu(holding: split.overflow)
            paletteEntryField
        }
    }

    private func pill(_ reaction: NCReaction) -> some View {
        Button {
            onToggle(reaction.emoji)
        } label: {
            NCChip(
                "\(reaction.emoji) \(reaction.count.formatted())",
                role: reaction.isMine ? .primary : .neutral
            )
        }
        .buttonStyle(.plain)
        .ncPointerStyle(.link)
        // On the `Button`, outside its label. `NCChip` combines its own children,
        // which makes the chip one element *inside* the button rather than a
        // second focusable one beside it, so the button is still what VoiceOver
        // lands on and this trait reaches it. Wrapping the button in a combine
        // would invert that and swallow the trait.
        .accessibilityAddTraits(reaction.isMine ? .isSelected : [])
    }

    private func overflowMenu(holding overflow: [NCReaction]) -> some View {
        Menu {
            ForEach(overflow) { reaction in
                Button {
                    onToggle(reaction.emoji)
                } label: {
                    Text(verbatim: "\(reaction.emoji) \(reaction.count.formatted())")
                }
            }
            if !overflow.isEmpty {
                Divider()
            }
            ForEach(frequent, id: \.self) { emoji in
                Button {
                    onToggle(emoji)
                } label: {
                    Text(verbatim: emoji)
                }
            }
            if NCEmojiPalette.isAvailable {
                Divider()
                Button {
                    catchingPaletteInsertion = true
                    NCEmojiPalette.present()
                } label: {
                    Text(LocalizedStringResource(nc: "More reactions…"))
                }
            }
        } label: {
            NCIcon(.plus, label: .decorative)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        // The plus glyph is 16pt, and this is the only route to the emoji
        // palette, so it gets the platform's hit target.
        .frame(
            minWidth: NCPlatformMetrics.minimumHitTarget,
            minHeight: NCPlatformMetrics.minimumHitTarget
        )
        .ncAccessibilityLabel(.text(LocalizedStringResource(nc: "Add reaction")))
    }

    /// Catches what the system palette inserts, and exists only while it is
    /// open.
    ///
    /// `orderFrontCharacterPalette` writes into the focused responder and
    /// returns nothing, so the only way to learn what was picked is to give it
    /// somewhere to write. A one-character field is that somewhere.
    ///
    /// Building it on demand is the whole point. A field that is always present
    /// is `.accessibilityHidden(true)` and still a tab stop, so a keyboard user
    /// hits an invisible one-pixel field between the reactions and whatever
    /// follows them. Here it is inserted by "More reactions…", takes focus as it
    /// appears, and is torn down again the moment it loses focus -- which
    /// happens when the person picks a character, dismisses the palette, or
    /// clicks anywhere else. The palette itself is a floating panel that does not
    /// take first responder, which is what makes this work at all.
    @ViewBuilder
    private var paletteEntryField: some View {
        if catchingPaletteInsertion {
            TextField(text: $paletteEntry) { EmptyView() }
                .textFieldStyle(.plain)
                .labelsHidden()
                .focused($paletteEntryFocused)
                .frame(width: 1)
                .opacity(0.01)
                .accessibilityHidden(true)
                .onAppear { paletteEntryFocused = true }
                .onChange(of: paletteEntryFocused) { _, focused in
                    if !focused { catchingPaletteInsertion = false }
                }
                .onChange(of: paletteEntry) { _, inserted in
                    // ponytail: the first grapheme cluster, not a validated
                    // emoji. The palette also inserts letters and symbols, and
                    // the server stores whatever it is sent. Add a check when a
                    // server-side constraint appears, not before.
                    guard let picked = inserted.first.map(String.init) else { return }
                    paletteEntry = ""
                    catchingPaletteInsertion = false
                    onToggle(picked)
                }
        }
    }
}
