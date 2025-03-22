// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MlemMiddleware",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MlemMiddleware",
            targets: ["MlemMiddleware"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/groue/Semaphore.git", .upToNextMajor(from: "0.0.8")),
        .package(url: "https://github.com/kean/Nuke.git", .upToNextMajor(from: "12.6.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/JohnSundell/CollectionConcurrencyKit.git", .upToNextMajor(from: "0.2.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MlemMiddleware",
            dependencies: [
                .product(name: "Semaphore", package: "Semaphore"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                .product(name: "CollectionConcurrencyKit", package: "CollectionConcurrencyKit")
            ],
            swiftSettings: [.enableUpcomingFeature("BareSlashRegexLiterals")]
        ),
        .testTarget(
            name: "MlemMiddlewareTests",
            dependencies: ["MlemMiddleware"]
        )
    ]
)
