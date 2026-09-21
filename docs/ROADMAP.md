<!--
SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
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
| 1 — Atoms | `NCIcon` + catalogue, `NCCounterBubble`, `NCChip`, `NCHighlight`, `NCNoteCard`, `NCUserStatusBadge`, `NCKeyboardShortcutLabel` | **Done** (icon assets pending) |
| 2 — Identity | `NCAsyncImage` + cache, `NCAvatar`, `NCUserBubble`, `NCProfileCard` | Next |
| 3 — Lists | `NCListItem`, `NCListItemDetails`, `NCEmptyContent` | |
| 4 — Navigation | `NCNavigationItem`, `NCNavigationCaption`, `NCBreadcrumbs`, `NCSettingsSection` | |
| 5 — Input | `NCButtonStyle`, `NCLabelStyle`, `NCUserPicker`, `NCReactionPicker`, progress style | |
| 6 — Polish | Accessibility pass, DocC catalogue, `Nc*` → `NC*` migration table | |

Wave 0 was a hard serial dependency — everything reads it.

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
- **Icon assets.** The catalogue defines all 91 names upstream imports and every
  symbol currently falls back to SF Symbols (82 of 91 have an equivalent). See
  `Tools/mdi-to-symbolset/README.md`. Running it is a data change, not a code
  change.
- **Full visual regression coverage.** The target, workflows and rebaseline
  command exist; only the wave 1 atoms are covered so far.
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

Build one Mail screen — mailbox sidebar, message list, message header with
avatar and recipients — in a scratch app against the package. That exercises
`NCNavigationItem`, `NCCounterBubble`, `NCListItem`, `NCAvatar` and
`NCUserPicker` together and will surface API problems no unit test finds. Do it
at the end of wave 3, not at the end of the project.
