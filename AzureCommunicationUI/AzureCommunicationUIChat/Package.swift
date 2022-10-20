// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AzureCommunicationUIChat",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "AzureCommunicationUIChat",
            targets: ["AzureCommunicationUIChat"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/microsoft/fluentui-apple.git",
            exact: .init(0, 4, 9)
        ),
        .package(
            url: "https://github.com/Azure/SwiftPM-AzureCommunicationChat.git",
            from: .init(1, 2, 0)
        ),
        .package(
            url: "https://github.com/Azure/SwiftPM-AzureCommunicationCommon.git",
            from: .init(1, 1, 0)
        ),
        .package(path: "../sdk/AzureCommunicationUICommon")
    ],
    targets: [
        .target(
            name: "AzureCommunicationUIChat",
            dependencies: [
                .product(name: "AzureCommunicationChat", package: "SwiftPM-AzureCommunicationChat"),
                .product(name: "AzureCommunicationUICommon", package: "AzureCommunicationUICommon")
            ],
            swiftSettings: [
                .unsafeFlags(
                    ["-enable-library-evolution"]
                )
            ]
        ),
        .testTarget(
            name: "AzureCommunicationUIChatTests",
            dependencies: ["AzureCommunicationUIChat"]),
    ],
    swiftLanguageVersions: [.v5]
)
