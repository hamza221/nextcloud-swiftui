#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Multiplatform discipline. These are hard failures: "no AppKit outside an
# isolated layer" has to be a build error rather than something a reviewer is
# expected to catch.
#
# Runs on Linux (ubuntu runner) -- it is pure grep, no toolchain needed.

set -uo pipefail
cd "$(dirname "$0")/.."

status=0

fail() {
    printf '\n\033[31mFAIL\033[0m  %s\n' "$1"
    shift
    printf '      %s\n' "$@"
    status=1
}

pass() { printf '\033[32mok\033[0m    %s\n' "$1"; }

# 1. AppKit/Cocoa/UIKit may only be imported under Sources/NextcloudPlatform/.
hits=$(grep -rnE '^\s*(@_implementationOnly\s+)?(public\s+|internal\s+)?import\s+(AppKit|UIKit|Cocoa)\b' \
        Sources --include='*.swift' \
        | grep -v '^Sources/NextcloudPlatform/' || true)
if [ -n "$hits" ]; then
    fail "UI framework imported outside the platform layer" "$hits" \
         "Add a SwiftUI-typed abstraction in Sources/NextcloudPlatform/ instead."
else
    pass "no AppKit/UIKit/Cocoa imports outside NextcloudPlatform"
fi

# 2. #if os(...) is forbidden outside the platform layer. Inside it, the idiom is
#    #if canImport(AppKit), which keeps the condition about capability rather
#    than about a platform name.
hits=$(grep -rnE '#if\s+(!\s*)?os\s*\(' Sources --include='*.swift' \
        | grep -v '^Sources/NextcloudPlatform/' || true)
if [ -n "$hits" ]; then
    fail "#if os() outside the platform layer" "$hits" \
         "Use #if canImport(AppKit) inside NextcloudPlatform."
else
    pass "no #if os() outside NextcloudPlatform"
fi

# 3. NextcloudDesign is the portability canary: it may import only SwiftUI,
#    Foundation, CryptoKit and Observation.
allowed='SwiftUI|Foundation|CryptoKit|Observation'
hits=$(grep -rhnE '^\s*(public\s+|internal\s+)?import\s+' \
        Sources/NextcloudDesign --include='*.swift' \
        | sed -E 's/.*import[[:space:]]+([A-Za-z_][A-Za-z0-9_.]*).*/\1/' \
        | sort -u | grep -vE "^($allowed)$" || true)
if [ -n "$hits" ]; then
    fail "NextcloudDesign imports outside the allow-list" "$hits" \
         "Allowed: SwiftUI, Foundation, CryptoKit, Observation."
else
    pass "NextcloudDesign imports stay within the allow-list"
fi

# 4. AsyncImage is banned everywhere: it uses URLSession.shared, which would put
#    networking inside a package declared network-free, and would bypass the
#    app's authenticated session. Nextcloud avatar endpoints need auth, so it
#    returns 401 on every private instance.
hits=$(grep -rn '\bAsyncImage\b' Sources --include='*.swift' || true)
if [ -n "$hits" ]; then
    fail "AsyncImage used" "$hits" \
         "Take an @Sendable () async throws -> Image loader from the app instead."
else
    pass "no AsyncImage"
fi

# 5. Public API must not expose NS*/UI* types.
hits=$(grep -rnE 'public\s+(final\s+)?(func|var|let|struct|class|actor|enum|typealias|init)[^\n]*\b(NS|UI)[A-Z]' \
        Sources --include='*.swift' || true)
if [ -n "$hits" ]; then
    fail "platform type in public API" "$hits" \
         "Wrap it in a SwiftUI-typed surface in NextcloudPlatform."
else
    pass "no NS*/UI* types in public declarations"
fi

echo
if [ "$status" -ne 0 ]; then
    echo "platform discipline: FAILED"
else
    echo "platform discipline: all checks passed"
fi
exit "$status"
