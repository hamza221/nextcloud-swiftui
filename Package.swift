// swift-tools-version: 6.2
//
// SPDX-FileCopyrightText: Hamza Mahjoubi
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import PackageDescription

/// Settings applied to every target in the package.
///
/// `defaultIsolation(MainActor.self)` is the single biggest ergonomic win for a
/// UI package and is painful to retrofit, so it is set from day one. Targets
/// that need to run off the main actor (the value-type colour maths in
/// `NextcloudDesign`) opt out locally with `nonisolated`.
///
/// Do not add `.treatAllWarnings(as: .error)` here. It emits
/// `-warnings-as-errors`, and Xcode passes `-suppress-warnings` to every
/// package target it builds. swiftc rejects the pair with
/// `error: conflicting options '-warnings-as-errors' and '-suppress-warnings'`,
/// which kills the build of any app that depends on this package, before the
/// app's own code is ever compiled. The consumer cannot clear the suppression:
/// package targets build in a project Xcode synthesises. `swift build` on its
/// own never sees the flag, so the repo's own CI would not catch it.
///
/// Warnings are still errors. The flag now comes from the build command,
/// `swift build -Xswiftc -warnings-as-errors`, wired into `make build`,
/// `make test` and the build-and-test workflow. `-Xswiftc` applies to the root
/// package's targets and not to its dependencies, which is the scope we want.
let sharedSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
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
