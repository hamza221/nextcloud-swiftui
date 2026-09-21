# SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help
help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: ## Install the local git hooks
	git config core.hooksPath .githooks
	@echo "hooks installed (core.hooksPath=.githooks)"

.PHONY: build
build: ## Build all targets
	swift build

.PHONY: test
test: ## Run the unit tests
	swift test

.PHONY: showcase
showcase: ## Run the interactive component showcase
	swift run NextcloudShowcase

.PHONY: format
format: ## Apply formatting in place
	swift format --in-place --recursive --parallel Sources Tests Package.swift

.PHONY: lint
lint: lint-format lint-swiftlint lint-discipline ## Run every lint check

.PHONY: lint-format
lint-format: ## Check formatting without writing
	swift format lint --strict --recursive --parallel Sources Tests Package.swift

.PHONY: lint-swiftlint
lint-swiftlint: ## Run SwiftLint (design-system invariants)
	swiftlint lint --strict

.PHONY: lint-discipline
lint-discipline: ## Run the multiplatform-discipline checks
	./Scripts/check-platform-discipline.sh

.PHONY: lint-reuse
lint-reuse: ## Check REUSE/SPDX compliance
	reuse lint

.PHONY: portability
portability: ## Build the portable targets for iOS (the canary)
	xcodebuild build -scheme NextcloudDesign -destination 'generic/platform=iOS' -quiet
	xcodebuild build -scheme NextcloudIcons  -destination 'generic/platform=iOS' -quiet

# All three library targets, not just the one Pages publishes. `@_exported
# import` gives consumers one import line but does not merge symbol graphs, so
# DocC builds one archive per module and only a per-target build checks the
# tokens' and the icons' own curation.
.PHONY: docs
docs: ## Build the DocC archives
	NC_BUILD_DOCS=1 swift package --allow-writing-to-directory ./docs-build \
		generate-documentation \
		--target NextcloudUI --target NextcloudDesign --target NextcloudIcons \
		--transform-for-static-hosting --output-path ./docs-build

.PHONY: snapshots
snapshots: ## Re-record visual regression baselines (CI runner only)
	SNAPSHOT_TESTING_RECORD=all swift test --filter NextcloudUISnapshotTests

.PHONY: clean
clean: ## Remove build products
	rm -rf .build docs-build
