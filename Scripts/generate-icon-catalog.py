#!/usr/bin/env python3
# SPDX-FileCopyrightText: Hamza Mahjoubi
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Regenerate the typed Material Design Icons catalogue.

    Scripts/generate-icon-catalog.py Scripts/icon-manifest.txt

The manifest is one PascalCase MDI name per line. The floor is the 91 icons
@nextcloud/vue imports today; extract that set from a checkout with:

    grep -rhoE "from 'vue-material-design-icons/[A-Za-z0-9]+" src \\
      | sed "s|.*icons/||" | sort -u

Which icons to curate beyond that floor is a product conversation with Nextcloud
design, not something this script decides.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

OUTPUT = Path("Sources/NextcloudIcons/NCSymbolCatalog.swift")

# SF Symbols to fall back to until an MDI symbolset is generated for a name.
# Deliberately conservative: an entry here is one where the SF Symbol carries the
# same meaning, not merely a similar shape. Brand logos have no entry, because
# there is no system equivalent and a wrong one would be worse than a placeholder.
FALLBACKS = {
    "AccountGroup": "person.3", "AccountMultiple": "person.2.fill",
    "AccountMultipleOutline": "person.2", "AccountOutline": "person",
    "AlertOctagonOutline": "exclamationmark.octagon", "ArrowLeft": "arrow.left",
    "ArrowRight": "arrow.right", "BookmarkOutline": "bookmark",
    "BriefcaseOutline": "briefcase", "CalendarAccountOutline": "calendar",
    "Cancel": "xmark.circle", "Cash": "banknote", "Check": "checkmark",
    "CheckboxBlankCircle": "circle.fill", "CheckboxBlankOutline": "square",
    "CheckboxMarked": "checkmark.square.fill",
    "CheckboxMarkedCircleOutline": "checkmark.circle",
    "ChevronDown": "chevron.down", "ChevronRight": "chevron.right",
    "ChevronUp": "chevron.up", "Circle": "circle", "ClockOutline": "clock",
    "Close": "xmark", "CloudSearchOutline": "cloud", "Cog": "gearshape.fill",
    "CogOutline": "gearshape", "Comment": "bubble.left",
    "Contacts": "person.crop.rectangle.stack", "CreditCardOutline": "creditcard",
    "Delete": "trash.fill", "DeleteOutline": "trash", "DockRight": "sidebar.right",
    "DotsHorizontal": "ellipsis", "DotsHorizontalCircleOutline": "ellipsis.circle",
    "Download": "arrow.down.circle.fill", "DownloadOutline": "arrow.down.circle",
    "Eject": "eject", "Email": "envelope", "Eyedropper": "eyedropper",
    "FilterOutline": "line.3.horizontal.decrease", "Folder": "folder.fill",
    "FolderOutline": "folder", "FolderUpload": "folder.badge.plus",
    "FormatAlignCenter": "text.aligncenter", "FormatAlignLeft": "text.alignleft",
    "FormatAlignRight": "text.alignright", "FormatBold": "bold",
    "FormatItalic": "italic", "FormatTitle": "textformat.size",
    "FormatUnderline": "underline",
    "Fullscreen": "arrow.up.left.and.arrow.down.right",
    "HelpCircle": "questionmark.circle", "KeyOutline": "key", "Link": "link",
    "LinkVariant": "link", "LockOutline": "lock", "Magnify": "magnifyingglass",
    "MapMarkerOutline": "mappin.and.ellipse", "MenuDown": "chevron.down",
    "MenuUp": "chevron.up", "MicrophoneOff": "mic.slash", "MinusBox": "minus.square",
    "NoteText": "note.text", "NoteTextOutline": "note.text",
    "OpenInNew": "arrow.up.forward.square", "PaletteOutline": "paintpalette",
    "Pencil": "pencil", "PencilOutline": "pencil", "Plus": "plus",
    "RadioboxBlank": "circle", "RadioboxMarked": "largecircle.fill.circle",
    "SelectColor": "eyedropper.halffull", "ShareVariant": "square.and.arrow.up.fill",
    "ShareVariantOutline": "square.and.arrow.up", "Star": "star.fill",
    "StarOutline": "star", "TrashCanOutline": "trash",
    "TrayArrowDown": "tray.and.arrow.down", "Undo": "arrow.uturn.backward",
    "Upload": "arrow.up.circle", "Video": "video.fill", "VideoOutline": "video",
}

SWIFT_KEYWORDS = {
    "class", "enum", "extension", "func", "import", "init", "internal", "let",
    "operator", "private", "protocol", "public", "static", "struct", "subscript",
    "typealias", "var", "break", "case", "continue", "default", "defer", "do",
    "else", "for", "guard", "if", "in", "repeat", "return", "switch", "where",
    "while", "as", "catch", "false", "is", "nil", "self", "super", "throw",
    "true", "try",
}

HEADER = '''// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

// GENERATED FILE -- do not edit by hand.
// Regenerate with: Scripts/generate-icon-catalog.py Scripts/icon-manifest.txt

extension NCSymbol {
'''


def kebab(name: str) -> str:
    return re.sub(r"(?<!^)(?=[A-Z])", "-", name).lower()


def camel(name: str) -> str:
    lowered = name[0].lower() + name[1:]
    return f"`{lowered}`" if lowered in SWIFT_KEYWORDS else lowered


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2

    names = sorted({line.strip() for line in Path(sys.argv[1]).read_text().splitlines() if line.strip()})
    if not names:
        print("manifest is empty", file=sys.stderr)
        return 1

    unknown = sorted(set(FALLBACKS) - set(names))
    if unknown:
        print(f"note: {len(unknown)} fallback(s) not in the manifest: {', '.join(unknown)}", file=sys.stderr)

    by_kebab: dict[str, str] = {}
    lines = []
    for name in names:
        asset = kebab(name)
        if asset in by_kebab:
            print(f"name collision: {name} and {by_kebab[asset]} both map to {asset}", file=sys.stderr)
            return 1
        by_kebab[asset] = name

        fallback = FALLBACKS.get(name)
        rendered = f'"{fallback}"' if fallback else "nil"
        lines.append(f"    /// Material Design Icons `{asset}`.")
        decl = (
            f'    public static let {camel(name)} = NCSymbol(asset: "{asset}", '
            f"systemFallback: {rendered})"
        )
        # Wrap the way swift-format would, so `make lint-format` does not fight
        # the generator over the 120-column limit.
        if len(decl) > 120:
            lines.append(f"    public static let {camel(name)} = NCSymbol(")
            lines.append(f'        asset: "{asset}", systemFallback: {rendered})')
        else:
            lines.append(decl)
        lines.append("")

    covered = sum(1 for n in names if n in FALLBACKS)
    body = "\n".join(lines).rstrip() + "\n}\n"
    OUTPUT.write_text(HEADER + body, encoding="utf-8")
    print(f"wrote {len(names)} symbols to {OUTPUT} ({covered} with an SF Symbols fallback)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
