// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftUIKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SwiftUIKit",
            targets: [
                "SwiftUIKit"
            ]
        ),
        .executable(
            name: "SwiftUIKitDemo",
            targets: [
                "SwiftUIKitDemo"
            ]
        )
    ],
    targets: [
        .target(
            name: "SwiftUIKit"
        ),
        .target(
            name: "SwiftUIKitDemoSupport",
            dependencies: [
                "SwiftUIKit"
            ],
            path: "Examples/SwiftUIKitDemoSupport"
        ),
        .executableTarget(
            name: "SwiftUIKitDemo",
            dependencies: [
                "SwiftUIKitDemoSupport"
            ],
            path: "Examples/SwiftUIKitDemo"
        ),
        .testTarget(
            name: "SwiftUIKitTests",
            dependencies: [
                "SwiftUIKit",
                "SwiftUIKitDemoSupport"
            ]
        )
    ]
)
