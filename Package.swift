// swift-tools-version: 6.4

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ApproachableConcurrency"),
]

let package = Package(
    name: "offhand",
    platforms: [
        .macOS(.v26),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "offhand",
            dependencies: [
                "OffhandKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            swiftSettings: swiftSettings,
        ),
        .target(
            name: "OffhandKit",
            swiftSettings: swiftSettings,
        ),
        .testTarget(
            name: "OffhandKitTests",
            dependencies: ["OffhandKit"],
            swiftSettings: swiftSettings,
        ),
    ]
)
