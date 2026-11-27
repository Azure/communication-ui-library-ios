![A banner image that shows some use cases of the Calling library](https://github.com/Azure/communication-ui-library-ios/blob/main/docs/images/mobile-ui-library-calling-hero-image.png?raw=true)

# Azure Communication UI Mobile Library for iOS - Calling

![License](https://img.shields.io/github/license/Azure/communication-ui-library-ios)
![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen)
![Platforms](https://img.shields.io/badge/platforms-iOS_16%2B-lightgrey)

## Latest Release

- [Latest release](https://github.com/Azure/communication-ui-library-ios/releases?q=calling&expanded=true)

## Getting Started

Get started with Azure Communication Services by using the UI Library to integrate communication experiences into your applications. For detailed instructions to quickly integrate the UI Library functionalities visit the [Quick-start Documentation](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/ui-library/get-started-call?tabs=kotlin&pivots=platform-ios).

## Installation

### Requirements

- iOS 16+
- Xcode 26.4+
- Swift 5.9+

### Using Swift Package Manager

To add the UI Library to your Xcode project, choose **File > Add Package Dependencies...**, enter `https://github.com/Azure/communication-ui-library-ios`, and add the `AzureCommunicationUICalling` product to your app target.

To add it to a `Package.swift` manifest:

```swift
dependencies: [
    .package(url: "https://github.com/Azure/communication-ui-library-ios", from: "2.0.1")
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "AzureCommunicationUICalling", package: "communication-ui-library-ios")
        ]
    )
]
```

The package brings in [AzureCommunicationCalling](https://github.com/Azure/SwiftPM-AzureCommunicationCalling) 3.0.1 or later, [AzureCommunicationCommon](https://github.com/Azure/SwiftPM-AzureCommunicationCommon), [AzureCore](https://github.com/Azure/SwiftPM-AzureCore) and [FluentUI](https://github.com/microsoft/fluentui-apple).

### Using CocoaPods (2.0.1 and earlier)

CocoaPods trunk is read-only from December 2, 2026, so new versions of the library are distributed only with Swift Package Manager. Version 2.0.1 is the last version available on CocoaPods:

```ruby
pod 'AzureCommunicationUICalling', '2.0.1'
```

To migrate from CocoaPods, remove `AzureCommunicationUICalling` and `AzureCommunicationCalling` from your `Podfile`, run `pod install`, and add the package as described above.

### Manual Installation

If you prefer to add the library from a local copy of the repository, see the [Manual Installation](manual-installation.md) guide.

## Quick Sample

Replace `<GROUP_CALL_ID>` with your group id for your call, `<DISPLAY_NAME>` with your name, and `<USER_ACCESS_TOKEN>` with your token. For full instructions check out our [quickstart](https://docs.microsoft.com/azure/communication-services/quickstarts/ui-library/get-started-composites?tabs=kotlin&pivots=platform-ios) or get the completed [sample](https://github.com/Azure-Samples/communication-services-ios-quickstarts/tree/main/ui-calling).

```swift
let callCompositeOptions = CallCompositeOptions(displayName: "<DISPLAY_NAME>")
let communicationTokenCredential = try! CommunicationTokenCredential(token: "<USER_ACCESS_TOKEN>")

callComposite = CallComposite(credential: communicationTokenCredential, withOptions: callCompositeOptions)

callComposite?.launch(locator: .groupCall(groupId: UUID(uuidString: "<GROUP_CALL_ID>")!))
```

For more details on Mobile UI Library functionalities visit the [API Reference Documentation](https://azure.github.io/azure-sdk-for-ios/AzureCommunicationUICalling/index.html).

## Known Issues

Please refer to the [wiki](https://github.com/Azure/communication-ui-library-ios/wiki/Known-Issues-Calling) for known issues related to calling composite.
