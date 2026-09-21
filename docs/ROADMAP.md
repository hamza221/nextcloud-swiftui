<!--
SPDX-FileCopyrightText: Hamza Mahjoubi
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Roadmap

## Triage of the 100 upstream components

**Already SwiftUI — do not rebuild (~35).** `NcButton` is a `Button` plus a
`ButtonStyle`. Text fields are `TextField`/`SecureField`/`TextEditor`.
`NcCheckboxRadioSwitch` is `Toggle` and `Picker`. `NcModal`/`NcDialog` are
`.sheet`, `.alert`, `.confirmationDialog`. `NcActions`/`NcPopover` are `Menu`,
`.contextMenu`, `.popover`. `NcEmptyContent` is `ContentUnavailableView`.
`NcDateTimePicker` is `DatePicker`. `NcAppSettingsDialog` is a `Settings` scene.

The largest single deletion: `NcContent`, `NcAppContent`, `NcAppContentList`,
`NcAppContentDetails`, `NcAppNavigation`, `NcAppNavigationList`, `NcAppSidebar`
and `NcAppSidebarHeader` collapse into `NavigationSplitView` plus `.inspector`.
Eight components become one system view that ships with correct sidebar collapse,
toolbar merging and window restoration.

**Web problems that evaporate (~20).** `NcVNodes` (→ `@ViewBuilder`),
`NcIconSvgWrapper`, `NcThemeProvider` and `useIsDarkTheme`
(→ `@Environment(\.colorScheme)`), `NcEllipsisedOption`
(→ `.truncationMode(.middle)`), the focus-trap utilities (the system traps focus
in sheets), `useScopeIdAttrs`, `useHotKey` (→ `.keyboardShortcut`).
`NcHeaderButton` and `NcHeaderMenu` become `.toolbar` and `Commands`.

**The app owns them.** `contactsMenu`, `spawnDialog`, reference providers — all
violate the pure-presentation rule.

## Waves

| Wave | Contents | Status |
| --- | --- | --- |
| 0 — Foundation | Token types, `NCTheme` + environment, `NCContrast`, `NCBrand`, `NCUsernameColor`, `NCAvatarPalette`, `NCRelativeDateFormatter` | **Done** |
| 1 — Atoms | `NCIcon` + catalogue, `NCCounterBubble`, `NCChip`, `NCHighlight`, `NCNoteCard`, `NCUserStatusBadge`, `NCKeyboardShortcutLabel` | **Done** |
| 2 — Identity | `NCAsyncImage` + cache, `NCAvatar`, `NCUserBubble`, `NCProfileCard` | **Done** |
| 3 — Lists | `NCListItem`, `NCListItemDetails`, `NCEmptyContent` | **Done** (`NCEmptyContent` not built, see below) |
| 4 — Navigation | `NCNavigationItem`, `NCNavigationCaption`, `NCBreadcrumbs`, `NCSettingsSection` | **Done** (`NCSettingsSection` not built, see below) |
| 5 — Input | `NCButtonStyle`, `NCLabelStyle`, `NCUserPicker`, `NCReactionPicker`, progress style | **Done** |
| 6 — Polish | Accessibility pass, DocC catalogue, `Nc*` → `NC*` migration table | **Done** |

Wave 0 was a hard serial dependency — everything reads it.

## Two planned components were not built

`NCEmptyContent` and `NCSettingsSection` were each about to wrap a system view
and take behaviour away. `ContentUnavailableView` scales its glyph with Dynamic
Type and ships translated in every language Apple supports; `Form` with
`.formStyle(.grouped)` already draws the grouping, separators, label-column
alignment and window restoration that System Settings uses. Both decisions are
written up with the code to use instead, in `EmptyStates.md` and
`SettingsSections.md` in the DocC catalogue.

## Not yet built from the plan

- **The shipped showcase app.** `NextcloudShowcase` exists as one file with an
  inline `@State` knob per control, run with `make showcase`. Still to build: the
  three-target split (`NextcloudUIShowcaseKit` with shared knob infrastructure, a
  thin `@main` app, UI tests) and a notarized `.dmg` so designers can browse
  components without a toolchain. Live prop editing uses
  explicit typed knobs over `Binding`'s dynamic member subscript, not reflection:
  `Mirror` gives you `(label, value)` and no setter, and more importantly it
  reports that a property is a `Double` rather than that it is a corner radius in
  0–24 stepping by 2. A `@Showcase` macro is deferred, not rejected — the knob
  array is the stable contract either way, so it stays a pure code generator over
  an API built regardless. Revisit at ~40 demos.
- **An `actool` step for SwiftPM.** The 91 MDI symbolsets are generated and
  committed, but SwiftPM copies an asset catalogue without compiling it, so there
  is no `Assets.car` under `swift build` and `make showcase` still renders the SF
  Symbols fallbacks. Xcode compiles them and renders the real glyphs. `NCIcon`
  detects the missing `Assets.car` and falls back rather than drawing blank, so
  nothing regressed. The fix is a build-tool plugin, which CONTRIBUTING argues
  against on the grounds that a plugin taxes every incremental build for
  everyone. Worth a deliberate decision rather than a default.
- **Recording the visual regression baselines.** Every wave now has a snapshot
  suite, and only wave 1's baselines are committed. Baselines are recorded on the
  pinned CI runner image only, so the rest need one `/update-snapshots` run.
- **Release automation** (Developer ID signing, notarization, DMG) and the
  **Transifex pipeline**. Both deliberately deferred: translations churn on every
  string change until the API is stable, and there is nothing to release yet.

## Deferred to v1.1

`NCRichContenteditable` (needs `NSTextView` bridging, 3–4 person-weeks alone),
`NCRichText` (Mail needs HTML email in a `WKWebView` — a different problem, so
it is off the Mail critical path), `NCFilePicker`, `NCUploadPicker`,
`NCBlurHash`, the assistant components (gradient-heavy; the tokens are already
transcribed, but the components wait for Liquid Glass conventions for AI
affordances to settle), `NCTimezonePicker`, `NCSelectTags`,
`NCSavingIndicatorIcon`, `NCHotkeyList`, and `NCColorPickerPalette` — the system
`ColorPicker` is free-form, which is the wrong affordance for calendar and tag
colours, where Nextcloud uses a fixed named swatch grid.

## Open questions

- **Which ~150 icons to curate** is a product conversation with Nextcloud design.
  The library-only floor is the 91 currently imported. Budget a day.
- **Mac App Store distribution conflicts with AGPL's anti-tivoization terms.**
  Not a problem if the Mail client ships outside the store like the existing
  desktop client, but worth confirming before it becomes a surprise.

## The real test

Done, as the Mail screen demo in `NextcloudShowcase`: mailbox sidebar, message
list, message header with avatar. It exercises `NCNavigationItem`,
`NCCounterBubble`, `NCListItem`, `NCAvatar` and `NCUserBubble` together, which is
what surfaces API problems no unit test finds.

It is a showcase demo rather than a scratch app, so it still proves less than
building against the package from outside. A real Mail client remains the test
that counts.
