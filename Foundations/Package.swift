// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Foundations",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Models", targets: ["Models"]),
        .library(name: "NavigationBackport", targets: ["NavigationBackport"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "0.6.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "Tagged", package: "swift-tagged"),
            ],
            resources: [.process("Colors.xcassets")]
        ),

        .target(name: "NavigationBackport", dependencies: []),
        .testTarget(name: "NavigationBackportTests", dependencies: ["NavigationBackport"]),
    ]
)
