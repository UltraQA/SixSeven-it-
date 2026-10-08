// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SixSeven",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "SixSevenCore", targets: ["SixSevenCore"])
    ],
    targets: [
        .target(name: "SixSevenCore"),
        .testTarget(name: "SixSevenCoreTests", dependencies: ["SixSevenCore"])
    ]
)
