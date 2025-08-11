// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SegmentSingular",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "SegmentSingular",
            targets: ["SegmentSingular"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/segmentio/analytics-ios",
            from: "4.0.0"
        ),
        .package(
            url: "https://github.com/singular-labs/Singular-iOS-SDK", 
            from: "12.0.0"
        )
    ],
    targets: [
        .target(
            name: "SegmentSingular",
            dependencies: [
                .product(name: "Segment", package: "analytics-ios"),
                .product(name: "Singular", package: "Singular-iOS-SDK")
            ],
            publicHeadersPath: "include"
        )
    ]
)
