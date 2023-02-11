// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let sharedDependencies: [Target.Dependency] = [
    .product(name: "Dependencies", package: "swift-dependencies"),
    .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
    .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
    .product(name: "Tagged", package: "swift-tagged"),
]

let package = Package(
    name: "Features",
    platforms: [.iOS(.v16)],
    products: [
        
        // MARK: Shared

        .library(name: "Models", targets: ["Models"]),
        
        // MARK: Features

        .library(name: "EditStandupFeature", targets: ["EditStandupFeature"]),
        .library(name: "RecordStandupFeature", targets: ["RecordStandupFeature"]),
        .library(name: "StandupDetailFeature", targets: ["StandupDetailFeature"]),
        .library(name: "StandupsListFeature", targets: ["StandupsListFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.4"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "0.6.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.9.0"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "0.6.0"),
    ],
    targets: [
        
        // MARK: Shared

        .target(name: "Models", dependencies: [] + sharedDependencies, resources: [.process("Colors.xcassets")]),
        
        // MARK: Features

        .target(name: "EditStandupFeature", dependencies: ["Models"] + sharedDependencies),
        .testTarget(name: "EditStandupFeatureTests", dependencies: ["EditStandupFeature"]),
        
        .target(name: "RecordStandupFeature", dependencies: ["Models"] + sharedDependencies),
        .testTarget(name: "RecordStandupFeatureTests", dependencies: ["RecordStandupFeature"]),
        
        .target(name: "StandupDetailFeature", dependencies: ["Models"] + sharedDependencies),
        .testTarget(name: "StandupDetailFeatureTests", dependencies: ["StandupDetailFeature"]),
        
        .target(name: "StandupsListFeature", dependencies: ["Models"] + sharedDependencies),
        .testTarget(name: "StandupsListFeatureTests", dependencies: ["StandupsListFeature"]),
    ]
)
