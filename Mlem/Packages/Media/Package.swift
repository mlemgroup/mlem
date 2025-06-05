// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Media",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Media",
            targets: ["Media"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke.git", .upToNextMajor(from: "12.6.0")),
        .package(url: "https://github.com/SDWebImage/SDWebImageWebPCoder", .upToNextMajor(from: "0.14.6")),
        .package(path: "../MlemMiddleware"),
        .package(path: "../Rest")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Media",
            dependencies: [
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "SDWebImageWebPCoder", package: "SDWebImageWebPCoder"),
                .byName(name: "MlemMiddleware"),
                .byName(name: "Rest")
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
