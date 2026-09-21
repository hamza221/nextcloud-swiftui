// swift-tools-version: 6.2
//
// SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import PackageDescription

/// Settings applied to every target in the package.
///
/// `defaultIsolation(MainActor.self)` is the single biggest ergonomic win for a
/// UI package and is painful to retrofit, so it is set from day one. Targets
/// that need to run off the main actor (the value-type colour maths in
/// `NextcloudDesign`) opt out locally with `nonisolated`.
let sharedSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .treatAllWarnings(as: .error),
]

/// The DocC plugin is gated behind an environment variable so that consumers of
/// the package never have to resolve it. Build documentation with
/// `NC_BUILD_DOCS=1 swift package generate-documentation`.
let doccDependency: [Package.Dependency] =
    ProcessInfo.processInfo.environment["NC_BUILD_DOCS"] == nil
    ? []
    : [.package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3")]

let package = Package(
    name: "nextcloud-ui-swift",
    defaultLocalization: "en",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [
        .library(name: "NextcloudDesign", targets: ["NextcloudDesign"]),
        .library(name: "NextcloudUI", targets: ["NextcloudUI"]),
        .library(name: "NextcloudIcons", targets: ["NextcloudIcons"]),
    ],
    dependencies: doccDependency + [
        // Test-only. SwiftPM does not resolve a dependency that is used solely by
        // test targets when this package is consumed as a dependency, so this
        // never reaches a consumer's Package.resolved.
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.0")
    ],
    targets: [
        // Tokens and colour maths. No platform code: this target is the
        // portability canary and must compile for every Apple platform with no
        // conditionals.
        .target(
            name: "NextcloudDesign",
            resources: [.process("Resources")],
            swiftSettings: sharedSwiftSettings
        ),

        // The only target permitted to import AppKit/UIKit. Enforced by CI.
        .target(
            name: "NextcloudPlatform",
            dependencies: ["NextcloudDesign"],
            swiftSettings: sharedSwiftSettings
        ),

        // Split out because resources are the one thing the linker cannot
        // dead-strip; an app that never renders an icon should not pay for the
        // asset catalogue.
        .target(
            name: "NextcloudIcons",
            dependencies: ["NextcloudDesign"],
            resources: [.process("Resources")],
            swiftSettings: sharedSwiftSettings
        ),

        .target(
            name: "NextcloudUI",
            dependencies: ["NextcloudDesign", "NextcloudPlatform", "NextcloudIcons"],
            // A component's DocC extension sits beside the component it
            // documents, which CONTRIBUTING makes part of the definition of
            // done. SwiftPM otherwise reports each one as an unhandled file, and
            // `exclude` takes paths rather than a glob, so they are listed. Add
            // a line when you add a component.
            //
            // One directory keeps its `NC` prefix where its siblings drop it:
            // the unprefixed spelling is the word `nc_no_async_image` bans, and
            // the rule reads paths and preview names as well as code.
            exclude: [
                "Components/NCAsyncImage/NCAsyncImage.md",
                "Components/Avatar/NCAvatar.md",
                "Components/ListItem/NCListItem.md",
                "Components/ListItemDetails/NCListItemDetails.md",
                "Components/ProfileCard/NCProfileCard.md",
                "Components/UserBubble/NCUserBubble.md",
                "Components/Breadcrumbs/NCBreadcrumbs.md",
                "Components/NavigationCaption/NCNavigationCaption.md",
                "Components/NavigationItem/NCNavigationItem.md",
                "Components/ButtonStyle/NCButtonStyle.md",
                "Components/LabelStyle/NCLabelStyle.md",
                "Components/ProgressStyle/NCProgressStyle.md",
                "Components/ReactionPicker/NCReactionPicker.md",
                "Components/UserPicker/NCUserPicker.md",
            ],
            resources: [.process("Resources")],
            swiftSettings: sharedSwiftSettings
        ),

        // The live catalogue. `swift run NextcloudShowcase`.
        .executableTarget(
            name: "NextcloudShowcase",
            dependencies: ["NextcloudUI"],
            swiftSettings: sharedSwiftSettings
        ),

        .testTarget(
            name: "NextcloudDesignTests",
            dependencies: ["NextcloudDesign"],
            swiftSettings: sharedSwiftSettings
        ),
        .testTarget(
            name: "NextcloudUITests",
            dependencies: ["NextcloudUI"],
            swiftSettings: sharedSwiftSettings
        ),
        .testTarget(
            name: "NextcloudUISnapshotTests",
            dependencies: [
                "NextcloudUI",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            exclude: ["__Snapshots__"],
            swiftSettings: sharedSwiftSettings
        ),
    ]
)
