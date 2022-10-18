// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AzureCommunicationUICommon",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "AzureCommunicationUICommon",
            targets: ["AzureCommunicationUICommon"]),
    ],
    dependencies: [
//        .package(
//            url: "https://github.com/microsoft/fluentui-apple.git",
//            .exact(
//                .init(0, 4, 0)
//            )
//        )
    ],
    targets: [
        .target(
            name: "AzureCommunicationUICommon",
            dependencies: [
//                .product(name: "FluentUI", package: "fluentui-apple")
            ],
            swiftSettings: [
                .unsafeFlags(
                    ["-enable-library-evolution"]
                )
            ]
        ),
        .testTarget(
            name: "AzureCommunicationUICommonTests",
            dependencies: ["AzureCommunicationUICommon"]),
    ]
)
