![Hero Image](/docs/images/mobile-ui-library-chat-hero-image.png?raw=true)

# Azure Communication UI Mobile Library for iOS - Chat

![Cocoapods](https://img.shields.io/cocoapods/l/AzureCommunicationUIChat)
![CocoaPods Compatible](https://img.shields.io/cocoapods/v/AzureCommunicationUIChat)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/AzureCommunicationUIChat)

## Latest Release

- Public Preview: [1.0.0-beta.1](https://github.com/Azure/communication-ui-library-ios/releases/tag/AzureCommunicationUIChat_1.0.0-beta.1)

## Getting Started

Get started with Azure Communication Services by using the UI Library to integrate communication experiences into your applications. For detailed instructions to quickly integrate the UI Library functionalities visit the [Quick-start Documentation](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/ui-library/get-started-chat-ui-library?tabs=kotlin&pivots=platform-ios).

## Installation

### Requirements

- iOS 14+
- Xcode 13+
- Swift 5.0+

### Using CocoaPods

CocoaPods is a dependency manager. To set up with CocoaPods visit their [Getting Started Guide](https://guides.cocoapods.org/using/getting-started.html). To integrate UI Mobile Library into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'AzureCommunicationUIChat', '1.0.0-beta.1'
```

### Manual Installation
If you prefer importing Mobile UI Library as an Embedded Framework to your project, please see [Manual Installation](manual-installation.md) for instructions.

## Quick Sample

The Chat Composite requires two objects to work together, the adapter and the view.
The `ChatAdapter` requires a communication identifier, token credential, a thread id, end point url of the chat, and an optional display name.  
The `ChatCompositeView` is a SwiftUI view object that developers use to add to their View. It is initialized with the above adapter that you created.

```swift
let identifier = UnknownIdentifier(<ACS_IDENTIFIER>)
let communicationTokenCredential = try! CommunicationTokenCredential(token: <USER_ACCESS_TOKEN>)
self.chatAdapter = ChatAdapter(endpoint: <CHAT_ENDPOINT>,
                                 identifier: identifier,
                                 credential: communicationTokenCredential,
                                 threadId: <CHAT_THREAD_ID>,
                                 displayName: <DISPLAY_NAME>)
self.chatAdapter.connect() { _ in
    print("Chat connect completionHandler called")
}
let chatView = ChatCompositeView(with: chatAdapter)
```

For more details on Mobile UI Library functionalities visit the [API Reference Documentation](https://azure.github.io/azure-sdk-for-ios/AzureCommunicationUIChat/index.html) and [Quickstart](https://learn.microsoft.com/en-us/azure/communication-services/quickstarts/ui-library/get-started-chat-ui-library)

## Known Issues

Please refer to the [wiki](https://github.com/Azure/communication-ui-library-ios/wiki/Known-Issues-Chat) for known issues related to chat.
