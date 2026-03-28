// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RatingKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "RatingKit",
            targets: ["RatingKit"]
        ),
    ],
    targets: [
        .target(
            name: "RatingKit",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
