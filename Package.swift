// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftURLBuilder",
    products: [
        .library(
            name: "SwiftURLBuilder",
            targets: ["SwiftURLBuilder"]),
    ],
    targets: [
        .target(
            name: "SwiftURLBuilder",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "SwiftURLBuilderTests",
            dependencies: ["SwiftURLBuilder"],
            path: "Tests"),
    ]
)
