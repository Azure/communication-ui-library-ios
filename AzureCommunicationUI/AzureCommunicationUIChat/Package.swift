// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AzureCommunicationUIChat",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
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
            exact: .init(1, 2, 0)
        ),
        .package(
            url: "https://github.com/Azure/SwiftPM-AzureCommunicationCommon.git",
            exact: .init(1, 1, 0)
        ),
        .package(path: "../sdk/AzureCommunicationUICommon")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AzureCommunicationUIChat",
            dependencies: [
                .product(name: "FluentUI", package: "fluentui-apple"),
                .product(name: "AzureCommunicationCommon", package: "SwiftPM-AzureCommunicationCommon"),
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
    ]
)
