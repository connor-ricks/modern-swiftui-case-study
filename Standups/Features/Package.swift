// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.iOS(.v15)],
    products: [
        
        // MARK: Shared
        
        .library(name: "Models", targets: ["Models"]),
        .library(name: "SwiftUINavigationBackport", targets: ["SwiftUINavigationBackport"]),
        
        // MARK: Features
        
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
        
        .target(name: "Models", dependencies: [
            .product(name: "Tagged", package: "swift-tagged"),
            .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
        ]),
        
        .target(name: "SwiftUINavigationBackport", dependencies: [
            .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        ]),
        
        // MARK: Features
        
        .target(name: "RecordStandupFeature", dependencies: [
            "Models",
            "SwiftUINavigationBackport",
            .product(name: "Dependencies", package: "swift-dependencies"),
            .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        ]),
        .testTarget(name: "RecordStandupFeatureTests", dependencies: ["RecordStandupFeature"]),
        
        .target(name: "StandupDetailFeature", dependencies: [
            "Models",
            "SwiftUINavigationBackport",
            "RecordStandupFeature",
            .product(name: "Dependencies", package: "swift-dependencies"),
            .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        ]),
        .testTarget(name: "StandupDetailFeatureTests", dependencies: ["StandupDetailFeature"]),
        
        .target(name: "StandupsListFeature", dependencies: [
            "Models",
            "SwiftUINavigationBackport",
            "StandupDetailFeature",
            .product(name: "Dependencies", package: "swift-dependencies"),
            .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        ]),
        .testTarget(name: "StandupsListFeatureTests", dependencies: ["StandupsListFeature"]),
    ]
)
