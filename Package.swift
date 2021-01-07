// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dyson",
    dependencies: [
        .package(name: "Files",
                 url: "https://github.com/JohnSundell/Files",
                 from: "4.2.0"),
        .package(url: "https://github.com/apple/swift-argument-parser",
                 .upToNextMinor(from: "0.3.0"))
    ],
    targets: [
        .target(
            name: "Dyson",
            dependencies: ["DysonCore"]),
        .target(
            name: "DysonCore",
            dependencies: ["Files",
                           .product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .testTarget(
            name: "DysonTests",
            dependencies: ["Dyson"]),
    ]
)
