![A banner image that shows the both of Calling and Chat libraries with a text that reads Azure Communication Service UI library](https://github.com/Azure/communication-ui-library-ios/blob/main/docs/images/mobile-ui-library-hero-image.png?raw=true)

# Azure Communication UI Mobile Library for iOS

Azure Communication [UI Mobile Library](https://docs.microsoft.com/en-us/azure/communication-services/concepts/ui-library/ui-library-overview) is an Azure Communication Services capability focused on providing UI components for common business-to-consumer and business-to-business calling interactions.

## Prerequisites

* An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).
* A Mac running [Xcode](https://go.microsoft.com/fwLink/p/?LinkID=266532), along with a valid developer certificate installed into your Keychain. [CocoaPods](https://cocoapods.org/) must also be installed to fetch dependencies.
* A deployed Communication Services resource. Create a [Communication Services resource](https://docs.microsoft.com/azure/communication-services/quickstarts/create-communication-resource).
* Azure Communication Services Token. [See example](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/identity/quick-create-identity).

## Libraries

Azure Communication Service Mobile UI currently offers the following libraries:

### [Calling](AzureCommunicationUI/sdk/AzureCommunicationUICalling)

<p>
<img width="50%" alt="A screenshot that shows some use cases of the Calling UI library." src="https://github.com/Azure/communication-ui-library-ios/blob/main/docs/images/calling.png?raw=true">
</p>

Calling experience allows users to start or join a call. Inside the experience, users can configure their devices, participate in the call with video, and see other participants, including those ones with video turned on. For Teams interoperability, CallComposite includes lobby functionality so that users can wait to be admitted. 

For more information about calling composite and how you can integrate it into your application, click [here](/AzureCommunicationUI/sdk/AzureCommunicationUICalling)

### [Chat](/AzureCommunicationUI/sdk/AzureCommunicationUIChat)

<p>
<img width="50%" alt="A screenshot that shows some use cases of the Chat UI library." src="https://github.com/Azure/communication-ui-library-ios/blob/main/docs/images/chat.png?raw=true">
</p>

Chat experience brings a real-time text communication to your applications. Specifically, users can send and receive a chat message with events from typing indicators and read receipt. In addition, users can also receive system messages such as participant added or removed and changes to chat title.

Learn more about how to integrate Chat to your applications, click [here](/AzureCommunicationUI/sdk/AzureCommunicationUIChat).

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
