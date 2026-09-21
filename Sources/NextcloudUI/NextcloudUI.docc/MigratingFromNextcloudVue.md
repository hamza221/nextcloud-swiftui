# Migrating from @nextcloud/vue

Where each of the 101 upstream components went.

## Overview

This is not a port, and the table below is the reason. Of the 101 components
`@nextcloud/vue` exports, 22 are rebuilt here. The rest are already a system API,
or solve a problem that only exists in a browser, or belong to the app rather
than to a presentation library, or are deliberately deferred.

Every component lands in exactly one of five buckets.

| Bucket | Count | What it means |
| --- | --- | --- |
| **Ships** | 22 | Rebuilt here, under an `NC*` name |
| **SwiftUI** | 51 | macOS 26 already has it. Use the system API named |
| **Browser** | 7 | The problem it solves does not exist outside a browser |
| **App** | 6 | It carries server state or credentials, which this package does not |
| **v1.1** | 15 | Deferred, with the reason |

The single largest deletion is in that SwiftUI column: `NcContent`,
`NcAppContent`, `NcAppContentList`, `NcAppContentDetails`, `NcAppNavigation`,
`NcAppNavigationList`, `NcAppSidebar` and `NcAppSidebarHeader` all collapse into
`NavigationSplitView` plus `.inspector`. Eight components become one system view
that arrives with correct sidebar collapse, toolbar merging and window
restoration already built.

The list is the `src/components/index.ts` barrel of `@nextcloud/vue` 9.13.0, the
current npm `latest`. A component that is not in that barrel is not in this
table. See <doc:MigratingFromNextcloudVue#If-you-are-still-on-v8> for the v8
delta.

## The table

| Upstream | Bucket | Use instead |
| --- | --- | --- |
| `NcActionButton` | SwiftUI | A `Button` inside a `Menu` |
| `NcActionButtonGroup` | SwiftUI | `ControlGroup` inside a `Menu` |
| `NcActionCaption` | SwiftUI | `Section(header:)` inside a `Menu` |
| `NcActionCheckbox` | SwiftUI | `Toggle` inside a `Menu` |
| `NcActionInput` | SwiftUI | A `TextField` in a `.popover`. A macOS menu does not take a text field |
| `NcActionLink` | SwiftUI | `Link` inside a `Menu` |
| `NcActionRadio` | SwiftUI | `Picker` with `.pickerStyle(.inline)` inside a `Menu` |
| `NcActionRouter` | App | Which route a menu item pushes is the app's `NavigationPath` |
| `NcActionSeparator` | SwiftUI | `Divider` |
| `NcActionText` | SwiftUI | A `Text` row in a `Menu` |
| `NcActionTextEditable` | SwiftUI | A `TextField` in a `.popover`, as `NcActionInput` |
| `NcActions` | SwiftUI | `Menu`, or `.contextMenu` for a right-click menu |
| `NcAppContent` | SwiftUI | The detail column of `NavigationSplitView` |
| `NcAppContentDetails` | SwiftUI | `.inspector`, or a third `NavigationSplitView` column |
| `NcAppContentList` | SwiftUI | The content column of `NavigationSplitView` |
| `NcAppNavigation` | SwiftUI | The sidebar column of `NavigationSplitView` |
| `NcAppNavigationCaption` | Ships | ``NCNavigationCaption`` |
| `NcAppNavigationIconBullet` | SwiftUI | A `Circle().fill(calendar.color)` in the row's leading slot |
| `NcAppNavigationItem` | Ships | ``NCNavigationItem`` |
| `NcAppNavigationList` | SwiftUI | A `List` in the sidebar. Nesting is `DisclosureGroup` |
| `NcAppNavigationNew` | SwiftUI | A `Button` above the `List`, with ``NCButtonStyle`` |
| `NcAppNavigationNewItem` | SwiftUI | A `TextField` in the row being created |
| `NcAppNavigationSearch` | SwiftUI | `.searchable(text:placement:)` |
| `NcAppNavigationSettings` | SwiftUI | A `Settings` scene, reached by `SettingsLink` |
| `NcAppNavigationSpacer` | SwiftUI | `Spacer` |
| `NcAppSettingsDialog` | SwiftUI | A `Settings` scene |
| `NcAppSettingsSection` | SwiftUI | `Form` and `Section`. See <doc:SettingsSections> |
| `NcAppSettingsSectionShortcuts` | v1.1 | Ships with `NcHotkeyList` |
| `NcAppSettingsShortcutsSection` | v1.1 | The older spelling of the same section |
| `NcAppSidebar` | SwiftUI | `.inspector` |
| `NcAppSidebarHeader` | SwiftUI | Content at the top of the inspector. ``NCProfileCard`` when it names a person |
| `NcAppSidebarTab` | SwiftUI | A `TabView` inside the inspector |
| `NcAssistantButton` | v1.1 | Waiting on Liquid Glass conventions for AI affordances. The gradient tokens are already transcribed |
| `NcAssistantContent` | v1.1 | Same |
| `NcAssistantIcon` | v1.1 | Same |
| `NcAutoCompleteResult` | Ships | A row of ``NCUserPicker`` |
| `NcAvatar` | Ships | ``NCAvatar`` |
| `NcBlurHash` | v1.1 | Deferred |
| `NcBreadcrumb` | Ships | ``NCBreadcrumbSegment`` |
| `NcBreadcrumbs` | Ships | ``NCBreadcrumbs`` |
| `NcButton` | SwiftUI | A `Button` with ``NCButtonStyle``. The system does the glass, the token supplies the hue |
| `NcCheckboxRadioSwitch` | SwiftUI | `Toggle`, `.toggleStyle(.switch)`, or `Picker` |
| `NcChip` | Ships | ``NCChip`` |
| `NcCollectionList` | App | Collections are a server feature. The rows are a `List` |
| `NcColorPicker` | v1.1 | The system `ColorPicker` is free-form, which is the wrong affordance for calendar and tag colours, where Nextcloud uses a fixed named swatch grid |
| `NcContent` | SwiftUI | `NavigationSplitView` |
| `NcCounterBubble` | Ships | ``NCCounterBubble`` |
| `NcDashboardWidget` | App | The Dashboard is a web app, and its widgets are its own |
| `NcDashboardWidgetItem` | App | The row itself is ``NCListItem``. What goes in it is the widget's |
| `NcDateTime` | Ships | ``NCRelativeDateText``, which keeps itself current on a schedule that relaxes as the date ages |
| `NcDateTimePicker` | SwiftUI | `DatePicker` |
| `NcDateTimePickerNative` | SwiftUI | `DatePicker`. On macOS there is only the native one |
| `NcDialog` | SwiftUI | `.alert`, `.confirmationDialog`, `.sheet` |
| `NcDialogButton` | SwiftUI | A `Button` in the alert's action builder, with `Button(role:)` |
| `NcEllipsisedOption` | Browser | `.truncationMode(.middle)`. CSS `text-overflow` truncates only at the end, so the web needs a component to fake the middle |
| `NcEmojiPicker` | Browser | macOS ships one, on `⌃⌘Space`, with search, skin tones, recents and every Unicode category. ``NCReactionPicker`` opens it |
| `NcEmptyContent` | SwiftUI | `ContentUnavailableView`. See <doc:EmptyStates> |
| `NcFilePicker` | v1.1 | Deferred |
| `NcFormBox` | SwiftUI | A `Form` row, or `GroupBox` |
| `NcFormBoxButton` | SwiftUI | A `Button` in a `Form` row |
| `NcFormBoxCopyButton` | SwiftUI | A `Button` with `.copyable(_:)` |
| `NcFormBoxSwitch` | SwiftUI | `Toggle` in a `Form` |
| `NcFormGroup` | SwiftUI | `Section` in a `Form` |
| `NcGuestContent` | App | Signing in means holding credentials, which this package does not do |
| `NcHeaderButton` | Browser | `.toolbar`. A web app builds its own top bar because it has none |
| `NcHeaderMenu` | Browser | `.toolbar` and `Commands`, which also puts the item in the menu bar |
| `NcHighlight` | Ships | ``NCHighlightText`` |
| `NcHotkey` | Ships | ``NCKeyboardShortcutLabel`` |
| `NcHotkeyList` | v1.1 | Deferred |
| `NcIconSvgWrapper` | Browser | An SVG string needs a DOM wrapper. Here an icon is `NCIcon` over an asset catalogue |
| `NcInputField` | SwiftUI | `TextField` |
| `NcKbd` | Ships | ``NCKeyboardShortcutLabel`` |
| `NcListItem` | Ships | ``NCListItem`` |
| `NcListItemIcon` | Ships | ``NCListItem`` with an ``NCAvatar`` in the leading slot |
| `NcLoadingIcon` | SwiftUI | `ProgressView()` |
| `NcMentionBubble` | Ships | ``NCUserBubble`` |
| `NcModal` | SwiftUI | `.sheet` |
| `NcNoteCard` | Ships | ``NCNoteCard`` |
| `NcPasswordField` | SwiftUI | `SecureField` |
| `NcPopover` | SwiftUI | `.popover` |
| `NcProfileHoverCard` | Ships | ``NCProfileCard`` in a `.popover` |
| `NcProgressBar` | Ships | A `ProgressView` with ``NCProgressStyle`` |
| `NcRadioGroup` | SwiftUI | `Picker` |
| `NcRadioGroupButton` | SwiftUI | One case of that `Picker` |
| `NcRelatedResourcesPanel` | App | It fetches related resources from the server |
| `NcRichContenteditable` | v1.1 | Needs `NSTextView` bridging, three to four person-weeks on its own |
| `NcRichText` | v1.1 | Mail needs HTML mail in a `WKWebView`, which is a different problem, so it is off the Mail critical path |
| `NcSavingIndicatorIcon` | v1.1 | Deferred |
| `NcSelect` | SwiftUI | `Picker` for a fixed list. A `.searchable` `List` when there are many options |
| `NcSelectTags` | v1.1 | Deferred |
| `NcSelectUsers` | Ships | ``NCUserPicker`` |
| `NcSettingsSection` | SwiftUI | `Form` and `Section`. See <doc:SettingsSections> |
| `NcSettingsSelectGroup` | Ships | ``NCUserPicker``. An ``NCUserCandidate`` id is an account, a federated cloud id or a group |
| `NcTextArea` | SwiftUI | `TextEditor`, or `TextField(axis: .vertical)` |
| `NcTextField` | SwiftUI | `TextField` |
| `NcThemeProvider` | Browser | `.ncTheme(_:)` and `@Environment(\.colorScheme)`. CSS custom properties have no ambient scope, so the web needs a provider component to create one |
| `NcTimezonePicker` | v1.1 | Deferred |
| `NcUploadPicker` | v1.1 | Deferred |
| `NcUserBubble` | Ships | ``NCUserBubble`` |
| `NcUserStatusIcon` | Ships | ``NCUserStatusBadge`` |
| `NcVNodes` | Browser | `@ViewBuilder` |

## Composables, directives and functions

`@nextcloud/vue` also exports composables, directives and plain functions. The
same five buckets apply.

| Upstream | Bucket | Use instead |
| --- | --- | --- |
| `useFormatRelativeTime` | Ships | ``NCRelativeDateText``, or `NCRelativeDateFormatter` for the string alone |
| `useFormatTime` | SwiftUI | `Text(date, format:)`, or `Duration.formatted` |
| `useHotKey` | SwiftUI | `.keyboardShortcut`. ``NCKeyboardShortcut`` holds one value that both binds and renders, so the documented shortcut cannot drift from the bound one |
| `useIsDarkTheme` | Browser | `@Environment(\.colorScheme)` |
| `useIsDarkThemeElement` | Browser | `@Environment(\.colorScheme)` |
| `useIsFullscreen` | App | Window state belongs to the app's `Scene` |
| `useIsMobile` | Browser | A viewport breakpoint. `NavigationSplitView` collapses on its own, and where a layout must still branch, `ViewThatFits` measures the space instead of guessing from a width |
| `useIsSmallMobile` | Browser | As `useIsMobile` |
| `MOBILE_BREAKPOINT` | Browser | As `useIsMobile` |
| `MOBILE_SMALL_BREAKPOINT` | Browser | As `useIsMobile` |
| `Focus` | SwiftUI | `@FocusState` with `.focused(_:)` |
| `Linkify` | SwiftUI | `Text` renders links in an `AttributedString`. `NSDataDetector` finds bare URLs in plain text |
| `isA11yActivation` | Browser | It asks whether a DOM event was Enter or Space on a focused element. A SwiftUI `Button` action already fires for the pointer, the keyboard and VoiceOver alike |
| `spawnDialog` | SwiftUI | `.sheet(isPresented:)` and `.alert`, driven by state the app owns |
| `emojiSearch` | Browser | The system palette has search |
| `emojiAddRecent` | Browser | The system palette keeps recents |
| `getCurrentSkinTone` | Browser | The system palette owns skin tone |
| `setCurrentSkinTone` | Browser | The system palette owns skin tone |
| `EmojiSkinTone` | Browser | The system palette owns skin tone |
| `checkIfDarkTheme` | Browser | `@Environment(\.colorScheme)` |
| `isDarkTheme` | Browser | `@Environment(\.colorScheme)` |
| `preloadImage` | Ships | ``NCImageCache``, which ``NCAsyncImage`` fills from the loader closure |
| `usernameToColor` | Ships | `NCUsernameColor`. All 36 vectors from the upstream Vitest snapshot are pinned as a test, so the same colleague is the same colour in both clients |
| `registerContactsMenuAction` | App | A server-backed registry |
| `getEnabledContactsMenuActions` | App | A server-backed registry |
| The reference registry | App | `hasInteractiveView`, `isWidgetRegistered`, `registerWidget`, `renderWidget`, `getLinkWithPicker`, `getReferenceWithPicker`, `anyLinkProviderId`, `getProvider`, `getProviders`, `searchProvider`, `sortProviders`, `isCustomPickerElementRegistered`, `registerCustomPickerElement`, `renderCustomPickerElement` and `NcCustomPickerRenderResult` are one registry of server-declared providers. The app owns it |

## If you are still on v8

`@nextcloud/vue` 8.41.0 is the npm `stable` tag and differs from 9.13.0 in five
places that matter here:

- `NcSettingsInputText` exists on v8 and was dropped in v9. It is a `TextField`
  in a `Form`.
- `NcChip`, `NcKbd` and `NcUploadPicker` are v9 additions. They are in the table
  above.
- The `Tooltip` directive is v8-only. macOS has `.help(_:)`, which is also what a
  VoiceOver reader hears.
- The `richEditor` and `userStatus` mixins are public on v8 and not on v9.
  `richEditor` belongs to `NcRichContenteditable`, deferred to v1.1;
  `userStatus` is ``NCUserStatus``.
- `useFormatDateTime` is v8-only, and is `Text(date, format:)`.

## Where the counts differ from the roadmap

`docs/ROADMAP.md` estimated roughly 35 already-SwiftUI components and roughly 20
browser-only ones. Counted against the actual barrel, the split is 51 and 7. The
difference is not a change of judgement: the roadmap's browser-only estimate
counted composables and utilities such as `useIsDarkTheme` and the focus-trap
helpers alongside components, and this table counts them separately. Several
things the roadmap filed as browser problems, such as the app-shell components,
are filed here under the system API that replaces them.

## See Also

- <doc:GettingStarted>
- <doc:EmptyStates>
- <doc:SettingsSections>
