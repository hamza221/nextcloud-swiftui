<!--
SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Material Design Icons to SF Symbol assets

Nextcloud uses Material Design Icons everywhere, and this package carries them
as **custom SF Symbol assets** rather than as plain images. That is not a
packaging detail: a symbol inherits font weight, `.imageScale`, Dynamic Type,
`.foregroundStyle`, hierarchical rendering and optical alignment with adjacent
text. An image inherits none of it, and an icon that does not optically align
with the label beside it is the most visible way a component reads as foreign.

## Status

**The pipeline is specified here but has not been run.** The catalogue
(`Sources/NextcloudIcons/NCSymbolCatalog.swift`) defines all 91 names that
`@nextcloud/vue` imports today, and `NCSymbol.bundledAssets` is empty, so every
symbol currently resolves through its SF Symbols fallback — 82 of the 91 have
one. The remaining nine (the four brand logos, the three horizontal-alignment
glyphs and the two hand glyphs) render a visible placeholder, which is the point:
a missing icon should be obvious in the showcase, not a silent gap.

Running the pipeline is a data change, not a code change. Nothing in
`NCIcon` needs to be touched.

## Steps

1. **Curate the set.** The library-only floor is the 91 in
   `Scripts/icon-manifest.txt`. The target is roughly 150, and which ones is a
   product conversation with Nextcloud design rather than a decision this
   pipeline makes. Budget a day for it.

2. **Fetch the SVGs** from [`Templarian/MaterialDesign`][mdi] at a pinned tag.
   Record the tag: an unpinned icon set is the same class of problem as an
   unpinned Xcode.

3. **Convert each SVG to a `.symbolset`.** MDI ships a 24x24 canvas with a
   20x20 live area. Export via the SF Symbols app's *Custom Symbol* template so
   the glyph lands on the correct baseline and cap-height guides; a raw SVG
   dropped into a symbolset renders at the wrong optical size beside text. Only
   the `Regular-M` variant is required — the app interpolates the rest.

4. **Write the assets** into
   `Sources/NextcloudIcons/Resources/Media.xcassets/`, one `.symbolset` per
   icon, named in MDI's own kebab-case (`folder-outline`, not `FolderOutline`)
   so the generated catalogue resolves them without a second mapping table.

5. **Regenerate the catalogue and the bundled set:**

   ```sh
   Scripts/generate-icon-catalog.py Scripts/icon-manifest.txt
   ```

   and populate `NCSymbol.bundledAssets` with the names actually written in
   step 4, so that a curated-but-not-yet-generated icon keeps falling back
   rather than rendering blank.

6. **Attribution.** MDI is Apache-2.0. Add `LICENSES/Apache-2.0.txt`, and a
   `REUSE.toml` annotation covering
   `Sources/NextcloudIcons/Resources/Media.xcassets/**` with
   `SPDX-FileCopyrightText: Austin Andrews and Material Design Icons contributors`
   and `SPDX-License-Identifier: Apache-2.0`. This is the step most likely to be
   forgotten and the one most likely to matter: `reuse lint` will catch it.

[mdi]: https://github.com/Templarian/MaterialDesign
