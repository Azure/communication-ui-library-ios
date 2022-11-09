// swift-tools-version: 5.6
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
    ],
    targets: [
        .target(
            name: "AzureCommunicationUICommon",
            dependencies: [],
            swiftSettings: [
                .unsafeFlags(
                    ["-enable-library-evolution"]
                )
            ]
        ),
        .testTarget(
            name: "AzureCommunicationUICommonTests",
            dependencies: ["AzureCommunicationUICommon"]
        ),
    ]
)
