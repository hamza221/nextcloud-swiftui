#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Regenerate the usernameToColor parity fixtures from @nextcloud/vue.

    git clone --depth 1 https://github.com/nextcloud-libraries/nextcloud-vue /tmp/ncvue
    Scripts/import-username-color-fixtures.py /tmp/ncvue

The vectors are the contract between this package and the web client: the same
account must produce the same avatar colour in both. Re-import rather than
hand-editing, and if a vector changes upstream, treat it as a deliberate
Nextcloud-wide palette change rather than a licence to edit the Swift port.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

SNAPSHOT = Path(
    "tests/unit/functions/usernameToColor/__snapshots__/usernameToColor.spec.ts.snap"
)
OUTPUT = Path("Tests/NextcloudDesignTests/Fixtures/NCUsernameColorFixtures.swift")

PATTERN = re.compile(
    r"exports\[`usernameToColor > (.*?) has the proper color \d+`\] = `\"(#[0-9a-f]{6})\"`;",
    re.S,
)

HEADER = """// SPDX-FileCopyrightText: 2020-2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

// GENERATED FILE -- do not edit by hand.
//
// Transcribed verbatim from @nextcloud/vue:
//   tests/unit/functions/usernameToColor/__snapshots__/usernameToColor.spec.ts.snap
//
// These vectors are the contract between this package and the web client. If one
// of them fails, the same person is rendering in two different colours depending
// on which Nextcloud client they opened, and the fix is in the Swift port -- not
// in this file.
//
// Regenerate with: Scripts/import-username-color-fixtures.py

internal nonisolated struct NCUsernameColorVector: Sendable {
    let username: String
    let hex: String
}

internal nonisolated enum NCUsernameColorFixtures {
    internal static let all: [NCUsernameColorVector] = [
"""


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2

    snapshot = Path(sys.argv[1]) / SNAPSHOT
    if not snapshot.is_file():
        print(f"no snapshot at {snapshot}", file=sys.stderr)
        return 1

    pairs = PATTERN.findall(snapshot.read_text(encoding="utf-8"))
    if not pairs:
        print("parsed no fixtures; the snapshot format probably changed", file=sys.stderr)
        return 1

    seen: set[str] = set()
    rows = []
    for name, colour in pairs:
        if name in seen:
            print(f"duplicate fixture {name!r}", file=sys.stderr)
            return 1
        seen.add(name)
        escaped = name.replace("\\", "\\\\").replace('"', '\\"')
        rows.append(f'        NCUsernameColorVector(username: "{escaped}", hex: "{colour}"),')

    OUTPUT.write_text(HEADER + "\n".join(rows) + "\n    ]\n}\n", encoding="utf-8")
    print(f"wrote {len(rows)} fixtures to {OUTPUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
