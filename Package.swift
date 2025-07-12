// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AgarCoreKit",
    platforms:  [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AgarCoreKit",
            targets: ["AgarCoreKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AgarCoreKit",
            dependencies: [],
            path: "Sources/AgarCoreKit",
            exclude: [],
            resources: [
                .process("Resources") // optional if you have .ahap, .wav, etc.
                ]
        ),
        .testTarget(
            name: "AgarCoreKitTests",
            dependencies: ["AgarCoreKit"],
            path: "Tests/AgarCoreKitTests"
        ),
    ]
)


