# ``NCUserPicker``

Pick one person, or several: a Mail recipient field, a Talk participant list, a
share sheet.

## Overview

```swift
@State private var recipients: Set<String> = []

NCUserPicker(candidates: contacts, selection: $recipients) { candidate in
    try await client.avatar(for: candidate.id)
}
```

Three parts, top to bottom: the people already picked, as removable
``NCChip``s; a search field; and the remaining candidates as ``NCListItem`` rows
with an ``NCAvatar`` each.

Two initialisers, because single and multiple selection are two different `List`
initialisers. Pass a `Binding<Set<String>>` for many and a `Binding<String?>` for
one. Faking either with the other loses `⌘`-click on the multiple side and
permits an impossible second selection on the single side.

## Selection belongs to `List`

The candidate list is a `List(selection:)`. That brings arrow-key traversal,
type-select, `⌘`-click, `⇧`-click ranges, the focus ring, the brand-tinted
highlight through `NCAccentPolicy`, and rows that report themselves as
selectable to VoiceOver.

This view adds no key handler and no tap gesture of its own. A hand-rolled
`onTapGesture` row is a worse copy that a keyboard cannot reach, and it is wrong
again in every appearance Apple ships next.

## A picked person leaves the list

Selecting someone moves them into a chip above the field, and they stop being
offered below it. That is what a recipient field does, and it is why
``NCUserSearch/matches(_:query:excluding:)`` takes an exclusion set.

Removal lives on the chip. ``NCChip`` surfaces it as an accessibility rotor
action rather than as a focusable button inside a combined element, so one swipe
removes a recipient instead of navigating into the chip first.

The chips sit on one horizontally scrolling line rather than wrapping. A wrapping
row needs a custom `Layout`, and a scrolling recipient field is what Mail.app
does.

## Filtering is not in this file

Substring matching, folding and ranking are in ``NCUserSearch``, which has no
SwiftUI in it. That is where the edge cases are, and where they are tested:

- an empty or whitespace-only query returns the whole pool, because an empty
  field means "no filter" rather than "no results"
- matching folds case, diacritics and full-width forms, so "mortel" finds
  "Mörtel" and a CJK keyboard's full-width Latin finds the same people as a
  Latin one
- display-name prefixes rank above secondary-field prefixes, which rank above
  anything merely containing the query
- within a tier the server's own order survives, so the list does not reshuffle
  as each letter is typed

What is left in `body` is composition.

## Empty states

`ContentUnavailableView.search(text:)` handles both "no matches for what you
typed" and "no candidates at all". The system already writes, translates and
lays out that message, so this component adds no string of its own for it.

## The search field keeps its name

The field passes both a `prompt` and a label, and then hides the label with
`.labelsHidden()`. That modifier is layout-only: the label is not drawn, and
assistive technology still reads it. The prompt is the placeholder, and a
placeholder disappears the moment a letter is typed — so without the label, the
field would lose its name exactly halfway through being filled in, which is the
worst moment to lose it. Dropping the label view and keeping only the prompt
would reintroduce that, and it is the one edit to make carefully here.

## Avatars

`load` is optional. Omit it and every row shows initials on the person's own
`NCUsernameColor`, which is what most Nextcloud accounts have anyway, and which
agrees with the web client exactly.

The avatars are `NCAccessibilityLabel.decorative`: the name is beside them in
text, and hearing it twice is how a recipient list becomes unbearable.

## Topics

### Candidates and matching

- ``NCUserCandidate``
- ``NCUserSearch``

## See Also

- ``NCAvatar``
- ``NCChip``
- ``NCListItem``
