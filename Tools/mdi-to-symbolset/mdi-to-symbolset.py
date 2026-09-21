#!/usr/bin/env python3
# SPDX-FileCopyrightText: Hamza Mahjoubi
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Convert Material Design Icons SVGs into SF Symbol `.symbolset` assets.

    Tools/mdi-to-symbolset/mdi-to-symbolset.py Scripts/icon-manifest.txt

Reads the manifest (one PascalCase MDI name per line), fetches the pinned MDI
release, and writes one `.symbolset` per name into the asset catalogue. See the
README beside this script for the placement derivation and for what to do after
running it.

Options:
    --only NAME[,NAME...]   Convert a subset, by kebab-case MDI name.
    --out DIR               Asset catalogue to write into.
    --cache DIR             Where to keep the downloaded MDI tarball.
    --scale FLOAT           Template units per MDI unit. Defaults to SCALE.
    --print-bundled         Print the Swift literal for NCSymbol.bundledAssets.
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
import tarfile
import urllib.request
from pathlib import Path

# --- The pinned icon set -----------------------------------------------------
#
# Templarian/MaterialDesign carries no git tags, so the pin is on
# Templarian/MaterialDesign-SVG, the SVG-only distribution of the same set (it
# is what the @mdi/svg npm package publishes). Tag and commit are both recorded
# so the download cannot silently move under us.
MDI_REPO = "Templarian/MaterialDesign-SVG"
MDI_TAG = "v7.4.47"
MDI_COMMIT = "9e04201d4557e729822fb57f62a316c3dea1d4a8"
MDI_TARBALL = f"https://codeload.github.com/{MDI_REPO}/tar.gz/{MDI_COMMIT}"
# sha256 of the tarball above, checked on every fetch.
MDI_TARBALL_SHA256 = "df6f844cb548946ecb5cfc138704492b446b169d78a406a752580d89747635cc"

# --- Apple's custom symbol template, v.3.0 -----------------------------------
#
# Every number below is read off an SVG that the SF Symbols app itself exported.
# The README derives the placement transform from them; do not nudge them.
CANVAS_W, CANVAS_H = 3300, 2200
# Baseline and capline of each scale row. Cap height is the same 70.459 in all
# three rows: the S/M/L difference lives in how large the glyph is drawn, not in
# the guides.
ROWS = {"S": (696.0, 625.541), "M": (1126.0, 1055.54), "L": (1556.0, 1485.54)}
CAP_HEIGHT = ROWS["S"][0] - ROWS["S"][1]  # 70.459
# Column centres, read off the weight labels in the template's Notes group.
COLUMNS = {"Ultralight": 559.711, "Regular": 1449.84, "Black": 2933.4}
# Vertical extent of the margin guide lines in the S row.
MARGIN_GUIDE_TOP, MARGIN_GUIDE_BOTTOM = 600.785, 720.121

# --- The placement transform -------------------------------------------------
#
# A symbol authored in the S row renders at `authored_units / 100` em at
# `.imageScale(.small)`, and at MEDIUM_SCALE_FACTOR times that at `.medium`,
# which is SwiftUI's default. Measured, not assumed: see the README.
MEDIUM_SCALE_FACTOR = 1.276
MDI_CANVAS = 24.0  # MDI ships every icon on a 24x24 canvas,
MDI_LIVE_AREA = 20.0  # with a 20x20 live area centred in it.
# Template units per MDI unit, chosen so the live area is one em tall at
# `.medium`. SF Symbols draws its own circle keyline at 0.9965 em there, so an
# MDI icon lands within 0.4% of a system glyph of the same shape.
SCALE = 100.0 / MDI_LIVE_AREA / MEDIUM_SCALE_FACTOR  # 3.9185

GUIDE_STYLE = "fill:none;stroke:#27AAE1;opacity:1;stroke-width:0.577;"
MARGIN_STYLE = "fill:none;stroke:#00AEEF;stroke-width:0.5;opacity:1.0;"
LABEL_STYLE = "stroke:none;fill:black;font-family:sans-serif;font-size:13;"

PATH_TOKEN = re.compile(r"[MmLlHhVvCcSsQqTtAaZz]|[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?")
# How many numbers each path command consumes, and which of those are lengths in
# x, in y, or neither (an arc's rotation and its two flags).
COMMAND_ARITY = {
    "M": 2, "L": 2, "T": 2, "H": 1, "V": 1, "C": 6, "S": 4, "Q": 4, "A": 7, "Z": 0,
}


def format_number(value: float) -> str:
    text = f"{value:.4f}".rstrip("0").rstrip(".")
    return "0" if text in ("", "-0") else text


def transform_path(data: str, scale: float, tx: float, ty: float) -> str:
    """Apply `scale` then `(tx, ty)` to every coordinate in an SVG path.

    Only uniform scaling and translation, which is all the placement transform
    needs, so arc radii scale and the arc rotation and flags pass through.
    """
    tokens = PATH_TOKEN.findall(data)
    out: list[str] = []
    index = 0
    command = ""
    while index < len(tokens):
        token = tokens[index]
        if token.isalpha():
            command = token
            out.append(token)
            index += 1
            if command in "Zz":
                continue
        elif not command:
            raise ValueError(f"path starts with a number: {data[:40]!r}")
        else:
            # A repeated argument group. After an M the implied command is L.
            command = {"M": "L", "m": "l"}.get(command, command)

        arity = COMMAND_ARITY[command.upper()]
        if arity == 0:
            continue
        args = [float(value) for value in tokens[index:index + arity]]
        if len(args) < arity:
            raise ValueError(f"path ends mid-command {command!r}")
        index += arity
        relative = command.islower()
        upper = command.upper()

        if upper == "H":
            args[0] = args[0] * scale + (0 if relative else tx)
        elif upper == "V":
            args[0] = args[0] * scale + (0 if relative else ty)
        elif upper == "A":
            args[0] *= scale
            args[1] *= scale
            args[5] = args[5] * scale + (0 if relative else tx)
            args[6] = args[6] * scale + (0 if relative else ty)
        else:
            for position in range(0, arity, 2):
                args[position] = args[position] * scale + (0 if relative else tx)
                args[position + 1] = args[position + 1] * scale + (0 if relative else ty)

        if upper == "A":
            # The two flags must stay single digits or the arc parses wrong.
            rendered = [format_number(args[0]), format_number(args[1]), format_number(args[2]),
                        str(int(args[3])), str(int(args[4])),
                        format_number(args[5]), format_number(args[6])]
        else:
            rendered = [format_number(value) for value in args]
        out.append(" ".join(rendered))
    return " ".join(out)


def read_mdi_path(svg: str) -> str:
    view_box = re.search(r'viewBox="([^"]+)"', svg)
    if not view_box or view_box.group(1).split() != ["0", "0", "24", "24"]:
        raise ValueError(f"unexpected viewBox {view_box and view_box.group(1)!r}")
    paths = re.findall(r'<path[^>]*\sd="([^"]+)"', svg)
    if len(paths) != 1:
        raise ValueError(f"expected exactly one path, found {len(paths)}")
    return paths[0]


def build_symbol_svg(name: str, mdi_path: str, scale: float) -> str:
    """Place one MDI path into Apple's custom symbol template."""
    half = MDI_CANVAS / 2 * scale  # Half the canvas, in template units.
    baseline, _ = ROWS["S"]
    # MDI y runs downwards from 0 at the top of the canvas. The canvas centre
    # lands on the midpoint between baseline and capline.
    offset_y = -half - CAP_HEIGHT / 2

    notes = [
        f'  <rect id="artboard" style="fill:white;opacity:1" x="0" y="0" '
        f'width="{CANVAS_W}" height="{CANVAS_H}"/>',
        f'  <text id="template-version" style="{LABEL_STYLE}text-anchor:end;" '
        f'transform="matrix(1 0 0 1 3036 1933)">Template v.3.0</text>',
        f'  <text id="descriptive-name" style="{LABEL_STYLE}text-anchor:end;" '
        f'transform="matrix(1 0 0 1 3036 1969)">Generated from mdi/{name}</text>',
    ]
    for weight, centre in COLUMNS.items():
        notes.append(
            f'  <text style="{LABEL_STYLE}text-anchor:middle;" '
            f'transform="matrix(1 0 0 1 {format_number(centre)} 322)">{weight}</text>'
        )
    for label, row in (("Small", "S"), ("Medium", "M"), ("Large", "L")):
        notes.append(
            f'  <text style="{LABEL_STYLE}" '
            f'transform="matrix(1 0 0 1 263 {format_number(ROWS[row][0] + 30)})">{label}</text>'
        )

    guides = []
    for row, (baseline_y, capline_y) in ROWS.items():
        guides.append(
            f'  <line id="Baseline-{row}" style="{GUIDE_STYLE}" x1="263" x2="3036" '
            f'y1="{format_number(baseline_y)}" y2="{format_number(baseline_y)}"/>'
        )
        guides.append(
            f'  <line id="Capline-{row}" style="{GUIDE_STYLE}" x1="263" x2="3036" '
            f'y1="{format_number(capline_y)}" y2="{format_number(capline_y)}"/>'
        )
    for weight, centre in COLUMNS.items():
        for side, edge in (("left", centre - half), ("right", centre + half)):
            guides.append(
                f'  <line id="{side}-margin-{weight}-S" style="{MARGIN_STYLE}" '
                f'x1="{format_number(edge)}" x2="{format_number(edge)}" '
                f'y1="{MARGIN_GUIDE_TOP}" y2="{MARGIN_GUIDE_BOTTOM}"/>'
            )

    # MDI has no weight axis, so every weight carries the same outline. The
    # symbol therefore does not thicken with font weight, which is honest: there
    # is no thicker drawing to interpolate towards.
    placed = transform_path(mdi_path, scale, 0.0, offset_y)
    symbols = []
    for weight, centre in COLUMNS.items():
        symbols.append(
            f'  <g id="{weight}-S" transform="matrix(1 0 0 1 '
            f'{format_number(centre - half)} {format_number(baseline)})">\n'
            f'   <path d="{placed}"/>\n'
            f"  </g>"
        )

    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        "<!--Generated by Tools/mdi-to-symbolset/mdi-to-symbolset.py-->\n"
        '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" '
        'xmlns:xlink="http://www.w3.org/1999/xlink" '
        f'width="{CANVAS_W}" height="{CANVAS_H}">\n'
        ' <g id="Notes">\n' + "\n".join(notes) + "\n </g>\n"
        ' <g id="Guides">\n' + "\n".join(guides) + "\n </g>\n"
        ' <g id="Symbols">\n' + "\n".join(symbols) + "\n </g>\n"
        "</svg>\n"
    )


def kebab(name: str) -> str:
    return re.sub(r"(?<!^)(?=[A-Z])", "-", name).lower()


def fetch_mdi(cache: Path) -> Path:
    """Download the pinned MDI tarball into `cache` and extract it. Idempotent."""
    import hashlib

    cache.mkdir(parents=True, exist_ok=True)
    tarball = cache / f"MaterialDesign-SVG-{MDI_TAG}.tar.gz"
    if not tarball.exists():
        print(f"fetching {MDI_REPO} {MDI_TAG} ({MDI_COMMIT[:12]})", file=sys.stderr)
        with urllib.request.urlopen(MDI_TARBALL, timeout=120) as response:
            tarball.write_bytes(response.read())
    digest = hashlib.sha256(tarball.read_bytes()).hexdigest()
    if digest != MDI_TARBALL_SHA256:
        tarball.unlink()
        raise SystemExit(f"tarball sha256 {digest} does not match the pin")
    root = cache / f"MaterialDesign-SVG-{MDI_COMMIT}"
    if not root.exists():
        with tarfile.open(tarball) as archive:
            archive.extractall(cache, filter="data")
    svg_dir = root / "svg"
    if not svg_dir.is_dir():
        raise SystemExit(f"no svg/ directory in {root}")
    return svg_dir


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--out", type=Path,
                        default=Path("Sources/NextcloudIcons/Resources/Media.xcassets"))
    parser.add_argument("--cache", type=Path, default=Path(".mdi-cache"))
    parser.add_argument("--only", default="")
    parser.add_argument("--scale", type=float, default=SCALE)
    parser.add_argument("--print-bundled", action="store_true")
    args = parser.parse_args()

    names = sorted({kebab(line.strip()) for line in args.manifest.read_text().splitlines()
                    if line.strip()})
    if args.only:
        wanted = {name.strip() for name in args.only.split(",") if name.strip()}
        missing = wanted - set(names)
        if missing:
            raise SystemExit(f"not in the manifest: {', '.join(sorted(missing))}")
        names = [name for name in names if name in wanted]
    if not names:
        raise SystemExit("nothing to convert")

    svg_dir = fetch_mdi(args.cache)
    args.out.mkdir(parents=True, exist_ok=True)
    contents = args.out / "Contents.json"
    if not contents.exists():
        contents.write_text(
            json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2) + "\n")

    written: list[str] = []
    for name in names:
        source = svg_dir / f"{name}.svg"
        if not source.exists():
            print(f"skip {name}: not in {MDI_REPO} {MDI_TAG}", file=sys.stderr)
            continue
        try:
            path_data = read_mdi_path(source.read_text())
        except ValueError as error:
            print(f"skip {name}: {error}", file=sys.stderr)
            continue
        symbolset = args.out / f"{name}.symbolset"
        if symbolset.exists():
            shutil.rmtree(symbolset)
        symbolset.mkdir()
        (symbolset / f"{name}.svg").write_text(
            build_symbol_svg(name, path_data, args.scale))
        (symbolset / "Contents.json").write_text(
            json.dumps(
                {
                    "info": {"author": "xcode", "version": 1},
                    "symbols": [{"filename": f"{name}.svg", "idiom": "universal"}],
                },
                indent=2,
            )
            + "\n"
        )
        written.append(name)

    print(f"wrote {len(written)} symbolset(s) to {args.out}", file=sys.stderr)
    if args.print_bundled:
        for name in written:
            print(f'        "{name}",')
    return 0 if len(written) == len(names) else 1


if __name__ == "__main__":
    raise SystemExit(main())
