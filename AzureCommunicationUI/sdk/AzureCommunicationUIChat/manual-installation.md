# Embedded Framework Installation

This documentation is meant to facilitate developers who wish to embed UI library manually without using Cocoapods. Since UI library contains couple of dependencies, you would need to embed those dependencies manually as well.

## Manual Installation Steps

1. Download, clone or submodule the latest [`AzureCommunicationUIChat`](https://github.com/Azure/azure-communication-ui-library-ios) Library to your project root directory ("<ROOT>").
2. Open your existing iOS application Xcode project in `xcworkspace`.
3. Drag the `AzureCommunicationUIChat.xcodeproj` from path `<ROOT>/AzureCommunicationUI/sdk/AzureCommunicationUIChat` into your Xcode project's `xcworkspace` in Xcode.
4. Select your application project in the Xcode Navigator, and open the target in which you want to import Mobile UI Library to.
5. Open the "General" panel and click on the `+` button under the "Frameworks, Libraries and Embedded Content" section.
6. Select `AzureCommunicationUIChat.framework` and click "Add." Now you can `import AzureCommunicationUIChat` inside your project to use Mobile UI Library.
7. Follow the [Dependencies Installation](#dependencies-installation) section to include all dependencies in your project.
8. Select project `AzureCommunicationUIChat.xcodeproj` in your workspace, open the target and scroll to the "Frameworks and Libraries" section, link dependent frameworks `libFluentUI.a`, `AzureCommunicationUIChat` and `AzureCommunicationCommon`. Set the frameworks to `Do Not Embed` for reducing the app size if needed.

### How to fix the issues

- **Buildtime issue: 'unable to open file(...)' - 'Pods-AzureCommunicationUIChat.debug.xcconfig...'**

    Navigate to the project `AzureCommunicationUIChat.xcodeproj` in Xcode, delete the whole folder `Pods` with red name.

- **Buildtime issue: 'Framework not found Pods-AzureCommunicationUIChat.'**

    1. Select Navigator and navigate to the target `AzureCommunicationUIChat`.
    2. Delete the `Pods-AzureCommunicationUIChat.framework` under "Frameworks and Libraries" section.

- **Buildtime issue: 'The sandbox is not in sync with the Podfile.lock.'**

    1. Select Navigator and navigate to the target `AzureCommunicationUIChat` and choose `Build Phases`.
    2. Delete the script `[CP] Check Pods Manifest.lock`.

### Dependencies Installation

The Chat UI Library requires a few dependencies. Please embed the following libraries into your project if you prefer manually embedding Mobile UI Library. And you can refer from each library's Podspec file for the required source files.

#### 1. [AzureCommunicationChat](https://github.com/Azure/azure-sdk-for-ios/tree/main/sdk/communication/AzureCommunicationChat) version: [1.3.0](https://github.com/Azure/azure-sdk-for-ios/releases/tag/AzureCommunicationChat_1.3.0)

- Drag the `AzureCommunicationChat.xcframework` into your project. Add it as embedded framework in your target's "Frameworks, Libraries and Embedded Content"  section.

#### 2. [AzureCommunicationCommon](https://github.com/Azure/azure-sdk-for-ios/tree/main/sdk/communication/AzureCommunicationCommon) - version [1.1.0](https://github.com/Azure/azure-sdk-for-ios/releases/tag/AzureCommunicationCommon_1.1.0)

- Find the project [AzureCommunicationCommon.xcodeproj](https://github.com/Azure/azure-sdk-for-ios/tree/main/sdk/communication/AzureCommunicationCommon) in the repo source code and drag it into your project.
- Follow [steps 1-6](#manual-installation-steps) of embedding `AzureCommunicationUIChat` and add `AzureCommunicationCommon` to your project.

#### 3. [Trouter](https://github.com/microsoft/trouter-client-ios) version: [0.1.0](https://github.com/microsoft/trouter-client-ios/releases/tag/v0.1.0)

- Download Trouter to your application folder
- In Xcode, expand `AzureCommunicationChat`, then expand "Frameworks", drag `Trouter.xcframework` to it.
- Remove old `Touter` reference under "Frameworks" which should be marked in red.


**Related Issues**

- **Buildtime issue: 'framework not found AzureCore'**

    1. Select Navigator and navigate to the target `AzureCommunicationCommon`.
    2. Delete the `AzureCore.framework` under "Frameworks and Libraries" section.

- **Buildtime issue: 'Swift Compiler Error'**

    1. Update the source code based on the error.
    2. Select Navigator and navigate to the target `AzureCommunicationCommon` and choose `Build Phases`.
    3. Delete the script `Format And Lint`.

#### 3. [MicrosoftFluentUI](https://github.com/microsoft/fluentui-apple) - version [0.3.9](https://github.com/microsoft/fluentui-apple/releases/tag/0.3.9_main_0.3)

- Follow this [Manual Installation Instruction](https://github.com/microsoft/fluentui-apple#manual-installation) to embed the `libFluentUI.a` in your target's "Frameworks and Libraries" section.

**Related Issues**

- **Runtime Crash With Fatal Error: 'FluentUI resource bundle is not found'**

    1. Select Navigator and navigate to the target `FluentUI.xcodeproj`, open the folder `Products` and you will see the `FluentUIResources-ios.bundle`. Right Click it and `Show in Finder` to find the bundle source in your finder.
    2. Select your own project and the target import FluentUI. Go to tab `Building Phases` and drag the `FluentUIResources-ios.bundle` to the `Copy Bundle Resources` section.
    3. Apply same update to the main target in the `AzureCommunicationUIChat.xcodeproj`, by adding the `FluentUIResources-ios.bundle` to the `Copy Bundle Resources` section.

- **Buildtime issue: 'Undefined symbol:...'**

    1. Update your target scheme with `ENABLE_ADDRESS_SANITIZER = YES`. For more instruction, please visit [How do you enable Clang Address Sanitizer in Xcode?](https://stackoverflow.com/questions/32150924/how-do-you-enable-clang-address-sanitizer-in-xcode).