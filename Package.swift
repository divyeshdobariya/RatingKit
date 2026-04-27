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
    
    dependencies: [
        // ✅ Add Google Mobile Ads SDK
        .package(
            url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
            from: "10.0.0"
        )
    ],
    
    targets: [
        .target(
            name: "RatingKit",
            dependencies: [
                .product(
                    name: "GoogleMobileAds",
                    package: "swift-package-manager-google-mobile-ads"
                )
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
