<!--
SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Visual regression baselines

**Generated only on the CI runner image. Never commit a baseline recorded on a
laptop.**

AppKit does not render deterministically across machines: font smoothing, GPU
differences and macOS point releases all shift pixels, and Liquid Glass is still
settling. A baseline recorded locally will differ from CI's on the very next run,
and the usual response — re-recording until it passes — destroys the signal.

To re-record, comment `/update-snapshots` on the pull request. The workflow
re-runs the suite with recording enabled on the pinned runner and pushes the
result to the branch.

A macOS point release warrants a deliberate mass rebaseline. That is expected,
not alarming — see CONTRIBUTING.md.
