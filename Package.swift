// swift-tools-version:5.9
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import PackageDescription

let sdkPath = "AzureCommunicationUI/sdk"
let callingPath = "AzureCommunicationUICalling"
let commonSourcesPath = "AzureCommunicationUICommon/Sources/AzureCommunicationUICommon"

let package = Package(
    name: "AzureCommunicationUICalling",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "AzureCommunicationUICalling",
            targets: ["AzureCommunicationUICalling"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/Azure/SwiftPM-AzureCommunicationCalling.git",
            from: "3.0.1"
        ),
        .package(
            url: "https://github.com/Azure/SwiftPM-AzureCommunicationCommon.git",
            from: "1.3.8"
        ),
        .package(
            url: "https://github.com/Azure/SwiftPM-AzureCore.git",
            exact: "1.0.0-beta.16"
        ),
        .package(
            url: "https://github.com/microsoft/fluentui-apple.git",
            exact: "0.10.0"
        )
    ],
    targets: [
        .target(
            name: "AzureCommunicationUICalling",
            dependencies: [
                .product(name: "AzureCommunicationCalling", package: "SwiftPM-AzureCommunicationCalling"),
                .product(name: "AzureCommunicationCommon", package: "SwiftPM-AzureCommunicationCommon"),
                .product(name: "AzureCore", package: "SwiftPM-AzureCore"),
                .product(name: "FluentUI", package: "fluentui-apple")
            ],
            path: sdkPath,
            // The target path is shared with UIChat and other non-Calling content,
            // which must be excluded so it is not picked up as resources.
            exclude: [
                "AzureCommunicationUIChat",
                "\(callingPath)/Tests",
                "\(callingPath)/AzureCommunicationUICalling.podspec",
                "\(callingPath)/CHANGELOG.md",
                "\(callingPath)/README.md",
                "\(callingPath)/manual-installation.md",
                "AzureCommunicationUICommon/Package.swift",
                "AzureCommunicationUICommon/README.md",
                "AzureCommunicationUICommon/Tests"
            ],
            // Resource folders must not be inside `sources`, otherwise SwiftPM treats them as
            // source files and does not generate Bundle.module. New top-level folders under
            // AzureCommunicationUICalling/Sources must be added here.
            sources: [
                "\(callingPath)/Sources/CallComposite.swift",
                "\(callingPath)/Sources/CallCompositeOptions",
                "\(callingPath)/Sources/Data",
                "\(callingPath)/Sources/Model",
                "\(callingPath)/Sources/Presentation",
                "\(callingPath)/Sources/Redux",
                "\(callingPath)/Sources/Service",
                "\(callingPath)/Sources/Utilities",
                commonSourcesPath
            ],
            resources: [
                .process("\(callingPath)/Sources/Assets.xcassets"),
                .process("\(callingPath)/Sources/Localization")
            ]
        ),
        .testTarget(
            name: "AzureCommunicationUICallingTests",
            dependencies: [
                "AzureCommunicationUICalling",
                .product(name: "AzureCommunicationCalling", package: "SwiftPM-AzureCommunicationCalling"),
                .product(name: "AzureCommunicationCommon", package: "SwiftPM-AzureCommunicationCommon"),
                .product(name: "FluentUI", package: "fluentui-apple")
            ],
            path: "\(sdkPath)/\(callingPath)/Tests",
            exclude: [
                "Info.plist",
                ".swiftlint.yml",
                "Service/CallHistoryRepositoryTests.swift.plist"
            ]
        )
    ]
)
