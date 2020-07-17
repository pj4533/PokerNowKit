// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "PokerNowKit",
    platforms: [
        .macOS("10.10")
    ],
    products: [
        .library(
            name: "PokerNowKit",
            targets: ["PokerNowKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.3.1"))
    ], 
    targets: [
        .target(
            name: "PokerNowKit",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift"),
            ],
            path: "PokerNowKit")
    ],
    swiftLanguageVersions: [.v5, .v4_2]
)