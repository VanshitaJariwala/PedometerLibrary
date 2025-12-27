// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PedometerLibrary",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PedometerLibrary",
            targets: ["PedometerLibrary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/simibac/ConfettiSwiftUI", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "PedometerLibrary",
            dependencies: [
                .product(name: "ConfettiSwiftUI", package: "ConfettiSwiftUI")
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)

