// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SixSeven",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SixSevenCore", targets: ["SixSevenCore"]),
        .library(name: "SixSevenUI", targets: ["SixSevenUI"])
    ],
    targets: [
        .target(name: "SixSevenCore"),
        .target(name: "SixSevenUI", dependencies: ["SixSevenCore"]),
        .testTarget(name: "SixSevenCoreTests", dependencies: ["SixSevenCore"])
    ]
)
