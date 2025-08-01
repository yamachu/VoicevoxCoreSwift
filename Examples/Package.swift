// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SampleAppCore",
    platforms: [
        .iOS(.v15),
        .macOS(.v15),
        .macCatalyst(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SampleAppCore",
            targets: ["SampleAppCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/mw99/DataCompression.git", from: "3.8.0"),
        .package(url: "https://github.com/kayembi/Tarscape.git", branch: "main"),
        // .package(url: "https://github.com/yamachu/VoicevoxCoreSwift.git", branch: "main"),
        .package(name: "VoicevoxCoreSwift", path: "../") // For local development
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SampleAppCore",
            dependencies: [
                "DataCompression",
                "Tarscape",
                "VoicevoxCoreSwift"
            ],
            resources: [
                .process("Resources/models.json")
            ]
        ),
        .testTarget(
            name: "SampleAppCoreTests",
            dependencies: ["SampleAppCore"]
        ),
    ]
)
