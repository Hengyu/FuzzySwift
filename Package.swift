// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FuzzySwift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "FuzzySwift", targets: ["FuzzySwift"]),
    ],
    targets: [
        .target(name: "FuzzySwift"),
        .testTarget(name: "FuzzySwiftTests", dependencies: ["FuzzySwift"]),
    ]
)
