# Azure Communication UI Mobile Library for iOS - Calling

![Hero Image](/docs/images/mobile-ui-library-calling-hero-image.png)

![Cocoapods](https://img.shields.io/cocoapods/l/AzureCommunicationUICalling)
![CocoaPods Compatible](https://img.shields.io/cocoapods/v/AzureCommunicationUICalling)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/AzureCommunicationUICalling)

## Latest Release

- Stable: [1.1.0 release](https://github.com/Azure/communication-ui-library-ios/releases/tag/AzureCommunicationUICalling_1.1.0)
- Public Preview: [1.2.0-beta.1](https://github.com/Azure/communication-ui-library-ios/releases/tag/AzureCommunicationUICalling_1.2.0-beta.1)

## Getting Started

Get started with Azure Communication Services by using the UI Library to integrate communication experiences into your applications. For detailed instructions to quickly integrate the UI Library functionalities visit the [Quick-start Documentation](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/ui-library/get-started-call?tabs=kotlin&pivots=platform-ios).

## Installation

### Requirements

- iOS 14+
- Xcode 13+
- Swift 5.0+

### Using CocoaPods

CocoaPods is a dependency manager. To set up with CocoaPods visit their [Getting Started Guide](https://guides.cocoapods.org/using/getting-started.html). To integrate UI Mobile Library into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'AzureCommunicationUICalling', '1.1.0'
```

### Manual Installation

If you prefer importing Mobile UI Library as an Embedded Framework to your project, please visit our [Manual Installation](manual-installation.md) guide.

## Quick Sample

Replace `<GROUP_CALL_ID>` with your group id for your call, `<DISPLAY_NAME>` with your name, and `<USER_ACCESS_TOKEN>` with your token. For full instructions check out our [quickstart](https://docs.microsoft.com/azure/communication-services/quickstarts/ui-library/get-started-composites?tabs=kotlin&pivots=platform-ios) or get the completed [sample](https://github.com/Azure-Samples/communication-services-ios-quickstarts/tree/main/ui-library-quick-start).

```swift
let callCompositeOptions = CallCompositeOptions()
let callComposite = CallComposite(withOptions: callCompositeOptions)
let communicationTokenCredential = try! CommunicationTokenCredential(token: "<USER_ACCESS_TOKEN>")
let remoteOptions = RemoteOptions(for: .groupCall(groupId: UUID("<GROUP_CALL_ID>")!),
                                  credential: communicationTokenCredential,
                                  displayName: "<DISPLAY_NAME>")
callComposite.launch(remoteOptions: remoteOptions)
```

For more details on Mobile UI Library functionalities visit the [API Reference Documentation](https://azure.github.io/azure-sdk-for-ios/AzureCommunicationUICalling/index.html).

## Known Issues

Please refer to the [wiki](https://github.com/Azure/communication-ui-library-ios/wiki/Known-Issues-Calling) for known issues related to calling composite.
