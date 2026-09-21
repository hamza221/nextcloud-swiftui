// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

#if canImport(AppKit)
internal import AppKit
#endif

/// The system emoji and symbol palette.
///
/// macOS ships an emoji picker with search, skin-tone variants, recents and
/// every Unicode category, and it is what `⌃⌘Space` opens everywhere else on the
/// machine. Rebuilding a grid of our own would be a worse copy that goes stale
/// with each Unicode release, so ``NCReactionPicker`` opens this instead.
///
/// - Important: The palette *inserts* into whatever is focused rather than
///   returning a value. A caller that needs the chosen character therefore
///   focuses a field first and reads what lands in it.
public enum NCEmojiPalette {

    /// Whether this platform has a palette to open.
    ///
    /// `false` means a caller should hide the affordance rather than show one
    /// that does nothing.
    public static var isAvailable: Bool {
        #if canImport(AppKit)
        true
        #else
        false
        #endif
    }

    /// Brings the palette to the front. A no-op where there is none.
    public static func present() {
        #if canImport(AppKit)
        NSApplication.shared.orderFrontCharacterPalette(nil)
        #endif
    }
}
