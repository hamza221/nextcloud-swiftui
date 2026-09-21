// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

/// The identity of an icon.
///
/// Icons ship as custom SF Symbol assets generated from Material Design Icons,
/// which is what Nextcloud uses everywhere else. Carrying them as symbols rather
/// than as images means they inherit weight, scale, `.foregroundStyle`,
/// hierarchical rendering and optical alignment with adjacent text for free.
///
/// Reach for the catalogue rather than a string:
///
/// ```swift
/// NCIcon(.folderOutline, label: .decorative)
/// ```
public nonisolated struct NCSymbol: Hashable, Sendable {
    /// The name of the generated symbol asset, in Material Design Icons' own
    /// kebab-case spelling.
    public let asset: String

    /// An SF Symbol carrying the same meaning, used until a symbol asset has
    /// been generated for ``asset``.
    ///
    /// `nil` where the system has no equivalent -- brand logos, and the few MDI
    /// glyphs with no counterpart. Those render a visible placeholder rather than
    /// a plausible-but-wrong system glyph.
    public let systemFallback: String?

    public init(asset: String, systemFallback: String? = nil) {
        self.asset = asset
        self.systemFallback = systemFallback
    }

    /// Names for which a generated symbol asset is bundled.
    ///
    /// One entry per `.symbolset` in `Resources/Media.xcassets`, written by
    /// `Tools/mdi-to-symbolset/mdi-to-symbolset.py`. A name missing from here
    /// resolves through ``systemFallback`` instead, so curating an icon into the
    /// manifest without generating its asset degrades to the system glyph rather
    /// than rendering blank.
    public static let bundledAssets: Set<String> = [
        "account-group",
        "account-multiple",
        "account-multiple-outline",
        "account-outline",
        "alert-octagon-outline",
        "align-horizontal-center",
        "align-horizontal-left",
        "align-horizontal-right",
        "arrow-left",
        "arrow-right",
        "bookmark-outline",
        "briefcase-outline",
        "calendar-account-outline",
        "cancel",
        "cash",
        "check",
        "checkbox-blank-circle",
        "checkbox-blank-outline",
        "checkbox-marked",
        "checkbox-marked-circle-outline",
        "chevron-down",
        "chevron-right",
        "chevron-up",
        "circle",
        "clock-outline",
        "close",
        "cloud-search-outline",
        "cog",
        "cog-outline",
        "comment",
        "contacts",
        "credit-card-outline",
        "delete",
        "delete-outline",
        "dock-right",
        "dots-horizontal",
        "dots-horizontal-circle-outline",
        "download",
        "download-outline",
        "eject",
        "email",
        "eyedropper",
        "filter-outline",
        "folder",
        "folder-outline",
        "folder-upload",
        "format-align-center",
        "format-align-left",
        "format-align-right",
        "format-bold",
        "format-italic",
        "format-title",
        "format-underline",
        "fullscreen",
        "hand-back-left-outline",
        "hand-back-right-outline",
        "help-circle",
        "instagram",
        "key-outline",
        "link",
        "link-variant",
        "lock-outline",
        "magnify",
        "map-marker-outline",
        "mastodon",
        "menu-down",
        "menu-up",
        "microphone-off",
        "minus-box",
        "note-text",
        "note-text-outline",
        "open-in-new",
        "palette-outline",
        "pencil",
        "pencil-outline",
        "plus",
        "radiobox-blank",
        "radiobox-marked",
        "select-color",
        "share-variant",
        "share-variant-outline",
        "star",
        "star-outline",
        "trash-can-outline",
        "tray-arrow-down",
        "twitch",
        "twitter",
        "undo",
        "upload",
        "video",
        "video-outline",
    ]

    /// Whether this symbol resolves to a bundled MDI asset rather than a
    /// fallback.
    public var hasBundledAsset: Bool { Self.bundledAssets.contains(asset) }
}
