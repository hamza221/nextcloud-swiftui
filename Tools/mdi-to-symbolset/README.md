<!--
SPDX-FileCopyrightText: Hamza Mahjoubi
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

Steps 2 to 6 have been run, for the 91 icons in `Scripts/icon-manifest.txt`:

- `Tools/mdi-to-symbolset/mdi-to-symbolset.py Scripts/icon-manifest.txt` wrote
  91 `.symbolset` bundles into `Sources/NextcloudIcons/Resources/Media.xcassets/`
  from MDI `v7.4.47`.
- `NCSymbol.bundledAssets` lists those same 91 names, so every symbol in the
  catalogue now resolves to a generated asset and none falls back.
- `Scripts/generate-icon-catalog.py Scripts/icon-manifest.txt` was re-run; the
  manifest did not change, so the catalogue came out byte-identical.
- `LICENSES/Apache-2.0.txt` and the MDI `REUSE.toml` annotation are in place and
  `reuse lint` passes.

Step 1, curating beyond the 91, has not been done. That is an open conversation
with Nextcloud design, tracked in `docs/ROADMAP.md`.

One thing did need a code change after all. SwiftPM copies `Media.xcassets` into
the resource bundle without running `actool`, so under `swift build` there is no
`Assets.car` and every symbol lookup comes back empty; only an Xcode build
compiles the catalogue. `NCIcon` now checks for `Assets.car` once and takes the
`systemFallback` path when it is absent, so `make showcase` and the snapshot
tests keep drawing system glyphs instead of 91 blank squares. Giving the package
a build-tool plugin that runs `actool` would remove the need for that check; it
is not worth a plugin target today.

The SF Symbols app was not used, because it has no command-line interface and is
not installed on the machine that ran this. The placement transform was derived
from Apple's own template geometry instead and checked by rendering; the
derivation is written out below so the next person can re-check it rather than
trust it.

## Steps

1. **Curate the set.** The library-only floor is the 91 in
   `Scripts/icon-manifest.txt`. The target is roughly 150, and which ones is a
   product conversation with Nextcloud design rather than a decision this
   pipeline makes. Budget a day for it.

2. **Fetch the SVGs** from [`Templarian/MaterialDesign`][mdi] at a pinned tag.
   Record the tag: an unpinned icon set is the same class of problem as an
   unpinned Xcode.

   That repository carries no git tags, so the pin is on
   [`Templarian/MaterialDesign-SVG`][mdi-svg], the SVG-only distribution of the
   same set and the source of the `@mdi/svg` npm package. The script pins tag
   `v7.4.47`, commit `9e04201d4557e729822fb57f62a316c3dea1d4a8`, and checks the
   tarball's sha256 on every fetch.

3. **Convert each SVG to a `.symbolset`.** MDI ships a 24x24 canvas with a
   20x20 live area. A raw SVG dropped into a symbolset renders at the wrong
   optical size beside text; the glyph has to land on the template's baseline
   and cap-height guides. See "Deriving the placement transform" below.

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
   `Sources/NextcloudIcons/Resources/Media.xcassets/**` whose
   `SPDX-FileCopyrightText` is "Austin Andrews and Material Design Icons
   contributors" and whose `SPDX-License-Identifier` is `Apache-2.0`. (Both tags
   are named without their colons here on purpose: `reuse` reads a full tag
   anywhere in a file, including inside prose.) This is the step most likely to
   be forgotten and the one most likely to matter: `reuse lint` will catch it.

## Running it

```sh
Tools/mdi-to-symbolset/mdi-to-symbolset.py Scripts/icon-manifest.txt
```

Plain Python 3, standard library only. It downloads the pinned tarball into
`.mdi-cache/` (gitignored) and rewrites every `.symbolset` it is asked for, so
re-running it is safe. `--only folder-outline,check` converts a subset,
`--print-bundled` prints the Swift literal for `NCSymbol.bundledAssets`.

## Deriving the placement transform

### The template geometry

Apple's *Custom Symbol* template (v.3.0) is a 3300x2200 SVG holding three
groups: `Notes`, `Guides` and `Symbols`. The SF Symbols app is the usual way to
get one, but the numbers it contains are fixed, and any symbol the app has ever
exported carries them. Three unrelated exports were compared and agree to the
last digit:

| Guide | Value |
| --- | --- |
| `Baseline-S` / `Capline-S` | y = 696 / 625.541 |
| `Baseline-M` / `Capline-M` | y = 1126 / 1055.54 |
| `Baseline-L` / `Capline-L` | y = 1556 / 1485.54 |
| Cap height, every row | 70.459 |
| Column centre, Ultralight / Regular / Black | x = 559.711 / 1449.84 / 2933.4 |

Two things fall out of that table. Cap height is the same 70.459 in all three
rows, so the S/M/L difference is not in the guides but in how large the artwork
is drawn against them. And the template is typeset at 100 points, so one
template unit is one hundredth of an em: 70.459 units is SF Pro's cap height
ratio of 0.70459 em.

A symbol group's `transform` puts its origin on the baseline and on the
left-margin guide, and its `left-margin-<Weight>-S` / `right-margin-<Weight>-S`
guides bracket the layout box. Current exports author only `Ultralight-S`,
`Regular-S` and `Black-S`; the system derives the other 24 combinations.

### The size

Two numbers are needed and only one of them is in the template.

The first is how an authored design turns into a rendered size. Measured by
compiling a known symbol and rasterising it at 1000 and 2000 points: a design of
*u* template units renders `u/100` em tall at `.imageScale(.small)`, `1.276 u/100`
em at `.medium`, and `1.647 u/100` em at `.large`, exactly, at both point sizes.

The second is what an MDI icon *should* measure. MDI's live area is 20 of its 24
units, and MDI's circle keyline (`circle`, `checkbox-blank-circle`) is a disc of
diameter 20 filling it. SF Symbols' own `circle` measures 0.9962 em at `.medium`,
which is SwiftUI's default `imageScale`. So the live area wants to be one em
there, and that fixes the scale:

```text
scale = 100 units per em / 20 live-area units / 1.276 = 3.9185 template units per MDI unit
```

The independent check is the square keyline. MDI's square (`checkbox-blank-outline`)
is 18 of 24 units, so this scale renders it at 0.900 em; SF Symbols' `square`
measures 0.899 em. Agreement to 0.1%, from a constant fitted only to the circle.

### The transform

MDI's canvas is 24 units wide and the glyph is centred in it, so the layout box
is 24 x 3.9185 = 94.044 template units and the margin guides sit half that
either side of the column centre. Vertically, the canvas centre lands on the
midpoint between baseline and capline, which is where Apple's own template
places its placeholder glyph (its circle sits at -35.16 against a cap midpoint of
-35.23).

For a point `(x, y)` on MDI's 24x24 canvas, in the local coordinates of a symbol
group whose origin is `(columnCentre - 47.022, baseline)`:

```text
X = 3.9185 x
Y = 3.9185 y - 82.252          where 82.252 = 12 x 3.9185 + 70.459/2
```

One uniform scale and one translation, the same for all 91 icons. Arc radii
scale with it; arc rotation and the two arc flags pass through unchanged.

MDI has no weight axis, so `Ultralight-S`, `Regular-S` and `Black-S` all carry
the same outline. An MDI icon therefore does not thicken with font weight. That
is honest rather than lossy: there is no heavier drawing to interpolate towards.

### How it was checked

`xcrun actool` compiles all 91 with no warnings or notices. Loading the compiled
`Assets.car` and rendering each one through `Image(_:bundle:)`, with no
`.resizable()` and no explicit frame:

- All 91 resolve and draw ink. None renders blank.
- Beside `Text` at `.body`, the circle keyline draws 1.41x cap height, matching
  SF Symbols' `circle` at 1.41x.
- In an `HStack`, the vertical offset between the glyph's centre and a capital
  H's centre is -0.040 cap height, for the generated symbols and for `circle`,
  `square` and `person` alike. The baseline placement is Apple's, to the pixel.

`dots-horizontal` draws at 0.28x cap height, which is correct: it is three dots
on a horizontal line and has no tall part.

[mdi]: https://github.com/Templarian/MaterialDesign
[mdi-svg]: https://github.com/Templarian/MaterialDesign-SVG
