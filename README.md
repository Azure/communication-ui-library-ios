![Hero Image](https://github.com/Azure/communication-ui-library-ios/blob/main/docs/images/mobile-ui-library-hero-image.png?raw=true)

# Azure Communication UI Mobile Library for iOS

![Cocoapods](https://img.shields.io/cocoapods/l/AzureCommunicationUICalling)
![CocoaPods Compatible](https://img.shields.io/cocoapods/v/AzureCommunicationUICalling)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/AzureCommunicationUICalling)

Azure Communication [UI Mobile Library](https://docs.microsoft.com/en-us/azure/communication-services/concepts/ui-library/ui-library-overview) is an Azure Communication Services capability focused on providing UI components for common business-to-consumer and business-to-business calling interactions.

## Getting Started

Get started with Azure Communication Services by using the UI Library to integrate communication experiences into your applications. For detailed instructions to quickly integrate the UI Library functionalities visit the [Quick-start Documentation](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/ui-library/get-started-call?tabs=kotlin&pivots=platform-ios).

### Prerequisites

* An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).
* A Mac running [Xcode](https://go.microsoft.com/fwLink/p/?LinkID=266532), along with a valid developer certificate installed into your Keychain. [CocoaPods](https://cocoapods.org/) must also be installed to fetch dependencies.
* A deployed Communication Services resource. Create a [Communication Services resource](https://docs.microsoft.com/azure/communication-services/quickstarts/create-communication-resource).
* Azure Communication Services Token. [See example](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/identity/quick-create-identity).

### Installation

#### Requirements

* iOS 14+
* Xcode 13+
* Swift 5.0+

#### Using CocoaPods

CocoaPods is a dependency manager for Cocoa projects. To set up with CocoaPods visit their [Getting Started Guide](https://guides.cocoapods.org/using/getting-started.html). To integrate UI Mobile Library into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'AzureCommunicationUICalling', '1.0.0'
```

#### Manual Installation


If you prefer importing Mobile UI Library as an Embedded Framework to your project, please visit our [Manual Installation](docs/manual-installation.md) guide.

### Quick Sample

Replace `<GROUP_CALL_ID>` with your group id for your call, `<DISPLAY_NAME>` with your name, and `<USER_ACCESS_TOKEN>` with your token.

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


## Contributing to the Library or Sample

Before developing and contributing to Communication Mobile UI Library, check out our [making a contribution guide](docs/contributing-guide.md).  
Included in this repository is a demo of using Mobile UI Library to start a call. You can find the detail of using and developing the UI Library in the [Demo Guide](AzureCommunicationUI/AzureCommunicationUIDemoApp).

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments. Also, please check our [Contribution Policy](CONTRIBUTING.md). 

## Community Help and Support

If you find a bug or have a feature request, please raise the issue on [GitHub Issues](https://github.com/Azure/azure-communication-ui-library-ios/issues).

## Known Issues

Please refer to the [wiki](https://github.com/Azure/azure-communication-ui-library-ios/wiki/Known-Issues) for known issues related to the library.


## Further Reading

* [Azure Communication UI Library Conceptual Documentation](https://docs.microsoft.com/azure/communication-services/concepts/ui-framework/ui-sdk-overview)
* [Azure Communication Service](https://docs.microsoft.com/en-us/azure/communication-services/overview)
* [Azure Communication Client and Server Architecture](https://docs.microsoft.com/en-us/azure/communication-services/concepts/client-and-server-architecture)
* [Azure Communication Authentication](https://docs.microsoft.com/en-us/azure/communication-services/concepts/authentication)
* [Azure Communication Service Troubleshooting](https://docs.microsoft.com/en-us/azure/communication-services/concepts/troubleshooting-info)
