<!--
SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Contributing

```sh
make setup     # git config core.hooksPath .githooks
make build
make test
make lint
```

## Commits and pull requests

[Conventional Commits][cc]. CI gates the **pull request title**, because
squash-merge makes the title the commit subject. A local `commit-msg` hook
checks individual commits as a convenience — it is 20 lines of shell
deliberately, since an npm toolchain (husky, commitlint) has no place in a Swift
repo.

Scopes: `design`, `icons`, `platform`, `ui`, `showcase`, `docs`, `ci`, `deps`,
or a component name such as `avatar` or `list-item`.

```
feat(design): add NCDynamicColor with a ShapeStyle conformance
fix(avatar): fall back to initials when the loader throws
```

Sign off your commits (`git commit -s`) — the DCO bot enforces it, matching
Nextcloud practice.

## Formatting and linting do different jobs

**`swift format` owns all formatting.** It ships with the toolchain, so there is
no version to drift. `--strict` in CI plus a pre-commit hook means layout never
appears in review.

**SwiftLint carries design-system invariants only** — no raw colour literals, no
`.system(size:)`, no magic padding numbers, no UIKit import, no `print`, no
`AsyncImage`. Those do more for consistency than every formatting rule combined.
Keep `.swiftlint.yml` small: a rule added there should encode an invariant, not a
preference. It runs as its own CI job, never as a build plugin, which would slow
every incremental build for everyone.

## Multiplatform discipline

`Scripts/check-platform-discipline.sh` is a hard failure. AppKit, UIKit and Cocoa
may only be imported under `Sources/NextcloudPlatform/`, and `#if os(...)` is
forbidden outside it — inside, the idiom is `#if canImport(AppKit)`, which keeps
the condition about capability rather than a platform name.

The greps matter less than the canary: `NextcloudDesign` and `NextcloudIcons`
must always build for iOS, and that is blocking. `NextcloudUI`'s iOS error count
is *reported* on every pull request rather than enforced. A rising number means
the incremental cost of adding iOS is growing, and the time to know is now.

Beyond the lint rules, the things that actually move that number:

- Every interaction has a non-hover path. A pointer cue is an enhancement.
- Sizes come from `theme.metrics.*`, never a literal.
- Use `List(selection:)` rather than hand-rolled selection.
- Express density as an environment value, not a compile-time constant.

## Adding a component

A component is not done until all of this exists:

```
Sources/NextcloudUI/Components/Avatar/
    NCAvatar.swift            # one public view per file
    NCAvatar+Previews.swift   # #if DEBUG
    NCAvatar.md               # DocC extension
```

1. **Extract the logic.** Every non-trivial view delegates to a plain struct or
   enum — `NCCounterFormat`, `NCHighlight` — that is fully testable with no
   SwiftUI involved. What remains in `body` should be composition that genuinely
   needs no test. This is an architecture decision, not a testing one, and it is
   the highest-leverage habit in the repo.
2. **Take an `NCAccessibilityLabel`**, non-optionally, on anything that conveys
   meaning without text.
3. **Slots are `@ViewBuilder` closures.** The default slot is the trailing
   closure. Ship a constrained convenience init
   (`extension NCChip where Leading == EmptyView`) so callers never write
   `leading: { EmptyView() }`. Cap generic parameters at three — past that the
   init-overload matrix is unreadable and the component needs decomposing.
4. **Never take a `Color` parameter unless it is data** (a calendar's colour, a
   tag's colour). If you are about to write `backgroundColor:`, the answer is a
   `role:` enum.
5. **Localise through `LocalizedStringResource(nc:)`.** A library string built
   without an explicit bundle resolves against the *app's* bundle and comes back
   untranslated — and it fails quietly, returning the English source, so it looks
   correct to an English-speaking developer and is broken for everyone else.
   Caller-supplied data stays a `String` and must not go through a table.
6. **Previews**, named `Component / scenario`, covering default, long content,
   empty, dark, increased contrast and RTL. RTL matters for Nextcloud
   specifically.

## Visual regression baselines

**Generated only on the CI runner image. Never commit a baseline recorded on a
laptop.**

AppKit does not render deterministically across machines — font smoothing, GPU
differences and macOS point releases all shift pixels, and Liquid Glass is still
settling. A locally recorded baseline will differ from CI's on the next run, and
the usual response (re-record until green) destroys the signal.

To re-record, comment `/update-snapshots` on the pull request. The workflow
re-runs the suite with recording enabled on the pinned runner and pushes the
result to your branch.

**Each macOS point release warrants a deliberate mass rebaseline.** This is
expected, not alarming. Precision is set to `0.99` / `0.98` perceptual for the
same reason.

For the first six months, treat a snapshot failure as an artefact to review
rather than a broken build. The job is `continue-on-error` accordingly.

## What we deliberately do not do

- **ViewInspector.** It reflects into SwiftUI's private view tree, which lags new
  OS releases — and we target macOS 26 with brand-new APIs, the exact worst case.
  The tests it enables are mostly tautological. Where it would test something
  real (conditional subview presence), extract the condition into a testable
  function instead.
- **Coverage targets.** A percentage gate on a presentation library incentivises
  exactly those tautological tests.
- **`ImageRenderer` for baselines.** It renders through SwiftUI only, so
  `NSViewRepresentable` content, vibrancy and materials come out blank or wrong.
  With Liquid Glass adopted throughout it would silently lie. It is fine for the
  render smoke test, which only checks that nothing crashes.
- **Library evolution.** We distribute source through SwiftPM; it costs
  performance and buys nothing.

[cc]: https://www.conventionalcommits.org
