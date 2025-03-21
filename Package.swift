// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VoicevoxCoreSwift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "VoicevoxCoreSwift",
            targets: ["VoicevoxCoreSwift"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.

        // #region Header only targets
        .target(
            name: "VoicevoxCoreSwiftMAC",
            dependencies: []
        ),
        .target(
            name: "VoicevoxCoreSwiftIOS",
            dependencies: []
        ),
        // #endregion
        .target(
            name: "VoicevoxCoreSwift",
            dependencies: ["VoicevoxCoreSwiftMAC", "VoicevoxCoreSwiftIOS"]
        ),
        .testTarget(
            name: "VoicevoxCoreSwiftTests",
            dependencies: ["VoicevoxCoreSwift"]
        ),
    ]
)
