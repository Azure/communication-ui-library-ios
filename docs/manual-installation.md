## Embedded Framework Installation

### Prerequisties

Azure Communication Mobile UI Library requires a few dependencies. Please import the following libraries into your project if you prefer manually embedding Mobile UI Library.  

- [MicrosoftFluentUI](https://github.com/microsoft/fluentui-apple)  
- [AzureCommunicationCalling](https://github.com/Azure/azure-sdk-for-ios/tree/main/sdk/communication/AzureCommunicationCalling)
- [SwiftLint](https://github.com/realm/SwiftLint)

### Manual Installation Steps

- Open Terminal and `cd` to your project root directory
- Run `git init` if there is no repository set up inside your project
- Add Mobile UI Library as a git [submodule](https://git-scm.com/docs/git-submodule):

```bash
git submodule add https://github.com/Azure/azure-communication-ui-library-ios
```

- Open the newly added folder from running the command and navigate into `AzureCommunicationUICalling` subfolder, drag the `AzureCommunicationUICalling.xcodeproj` into your Xcode project's Navigator
- Match the deployment target of `AzureCommunicationUICalling.xcodeproj` with your application target
- Select your application project in the Xcode Navigator, and open the target you want to import Mobile UI Library
- Open the "General" panel and click on the `+` button under the "Frameworks and Libraries" section
- Select `AzureCommunicationUICalling.framework` and then you can `import AzureCommunicationUICalling` inside the code to use Mobile UI Library 
