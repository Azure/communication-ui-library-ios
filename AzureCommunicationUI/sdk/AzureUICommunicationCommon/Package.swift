// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AzureUICommunicationCommon",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "AzureUICommunicationCommon",
            targets: ["AzureUICommunicationCommon"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AzureUICommunicationCommon",
            dependencies: [],
            swiftSettings: [
                .unsafeFlags(
                    ["-enable-library-evolution"]
                )
            ]
        ),
        .testTarget(
            name: "AzureUICommunicationCommonTests",
            dependencies: ["AzureUICommunicationCommon"]
        ),
    ]
)
