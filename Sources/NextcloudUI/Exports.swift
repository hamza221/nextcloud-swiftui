// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

/// Consumers write one import.
///
/// Every component here takes or returns design tokens, so a consumer that
/// imports `NextcloudUI` needs `NextcloudDesign` in essentially every file.
/// Re-exporting is the difference between one import line and two in each of a
/// consuming app's files, forever.
///
/// `@_exported` is underscored, but it has been stable for over a decade and is
/// used by the standard library itself. The alternative taxes every consumer
/// file permanently.
@_exported public import NextcloudDesign
/// The icon catalogue, for the same reason: a component that takes an
/// `NCSymbol` is unusable without it.
@_exported public import NextcloudIcons
