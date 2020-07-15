// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "PokerNowKit",
    platforms: [
        .macOS("10.14")
    ],
    products: [
        .library(
            name: "PokerNowKit",
            targets: ["PokerNowKit"]),
    ],
    dependencies: [], // No dependencies
    targets: [
        .target(
            name: "PokerNowKit",
            dependencies: [],
            path: "PokerNowKit")
    ],
    swiftLanguageVersions: [.v5, .v4_2]
)