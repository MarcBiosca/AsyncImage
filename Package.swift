// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncImage",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AsyncImage",
            targets: [
                "AsyncImage"
            ]
        ),
    ],
    targets: [
        .target(
            name: "AsyncImage",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "AsyncImageTests",
            dependencies: [
                "AsyncImage"
            ]
        ),
    ]
)
