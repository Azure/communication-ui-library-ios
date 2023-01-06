# Embedded Framework Installation

This documentation is meant to facilitate developers who wish to embed UI library manually without using Cocoapods. Since UI library contains a couple of dependencies, you would need to embed those manually as well.

## Manual Installation Steps

1. Download, clone or submodule the latest [`AzureCommunicationUICalling`](https://github.com/Azure/azure-communication-ui-library-ios) Library to your project root directory ("<ROOT>").
2. Open your existing iOS application Xcode project in `xcworkspace`.
3. Drag the `AzureCommunicationUICalling.xcodeproj` from path `<ROOT>/AzureCommunicationUI/sdk/AzureCommunicationUICalling` into your Xcode project's `xcworkspace` in Xcode.
4. Select your application project in the Xcode Navigator, and open the target in which you want to import Mobile UI Library to.
5. Open the "General" panel and click on the `+` button under the "Frameworks, Libraries and Embedded Content" section.
6. Select `AzureCommunicationUICalling.framework` and click "Add." Now you can `import AzureCommunicationUIChat` inside your project to use Mobile UI Library.
7. Follow the [Dependencies Installation](#dependencies-installation) section to include all dependencies in your project.
8. Select project `AzureCommunicationUICalling.xcodeproj` in your workspace, open the target and scroll to the "Frameworks and Libraries" section, link dependent frameworks `libFluentUI.a`, `AzureCommunicationCalling` and `AzureCommunicationCommon`. Set the frameworks to `Do Not Embed` for reducing the app size if needed.

### How to fix the issues

- **Buildtime issue: 'unable to open file(...)' - 'Pods-AzureCommunicationUICalling.debug.xcconfig...'**

    Navigate to the project `AzureCommunicationUICalling.xcodeproj` in Xcode, delete the whole folder `Pods` with red name.

- **Buildtime issue: 'Framework not found Pods_AzureCommunicationUICalling.'**

    1. Select Navigator and navigate to the target `AzureCommunicationUICalling`.
    2. Delete the `Pods_AzureCommunicationUICalling.framework` under "Frameworks and Libraries" section.

- **Buildtime issue: 'The sandbox is not in sync with the Podfile.lock.'**

    1. Select Navigator and navigate to the target `AzureCommunicationUICalling` and choose `Build Phases`.
    2. Delete the script `[CP] Check Pods Manifest.lock`.

### Dependencies Installation

Azure Communication Mobile UI Library requires a few dependencies. Please embed the following libraries into your project if you prefer manually embedding Mobile UI Library. And you can refer from each library's Podspec file for the required source files.

#### 1. [AzureCommunicationCalling](https://github.com/Azure/azure-sdk-for-ios/tree/main/sdk/communication/AzureCommunicationCalling) version: [2.2.1](https://github.com/Azure/Communication/releases/tag/v2.2.1)

- Drag the `AzureCommunicationCalling.xcframework` into your project. Add it as embedded framework in your target's "Frameworks and Libraries" section.

#### 2. [AzureCommunicationCommon](https://github.com/Azure/azure-sdk-for-ios/tree/main/sdk/communication/AzureCommunicationCommon) - version [1.1.0](https://github.com/Azure/azure-sdk-for-ios/releases/tag/AzureCommunicationCommon_1.1.0)

- Find the project [AzureCommunicationCommon.xcodeproj](https://github.com/Azure/azure-sdk-for-ios/tree/main/sdk/communication/AzureCommunicationCommon) in the repo source code and drag it into your project.
- Follow [steps 1-6](#manual-installation-steps) of embedding `AzureCommunicationUICalling` and add `AzureCommunicationCommon` to your project.

**Related Issues**
Note: Please refer to [How to fix the issues](#how-to-fix-the-issues) to fix some common issues.

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
The following issues may be present.

- **Runtime Crash With Fatal Error: 'FluentUI resource bundle is not found'**

    1. Select Navigator and navigate to the target `FluentUI.xcodeproj`, open the folder `Products` and you will see the `FluentUIResources-ios.bundle`. Right Click it and `Show in Finder` to find the bundle source in your finder.
    2. Select your own project and the target import FluentUI. Go to tab `Building Phases` and drag the `FluentUIResources-ios.bundle` to the `Copy Bundle Resources` section.
    3. Apply same update to the main target in the `AzureCommunicationUICalling.xcodeproj`, by adding the `FluentUIResources-ios.bundle` to the `Copy Bundle Resources` section.

- **Buildtime issue: 'Undefined symbol:...'**

    1. Update your target scheme with `ENABLE_ADDRESS_SANITIZER = YES`. For more instruction, please visit [How do you enable Clang Address Sanitizer in Xcode?](https://stackoverflow.com/questions/32150924/how-do-you-enable-clang-address-sanitizer-in-xcode).

### FAQ

#### How to conditionally use the UI library based on the iOS version when the project has a lower minimum deployment target?

The UI library won't work for devices lower than iOS 14 but it's still possible to import the UI library with the following workaround and then conditionally launch the UI library when iOS 14 is available.

1. Add a new framework to your project and set the minimum deployment target > iOS 14
    - Set the new wrapper framework to be a dependency of the main project, but ensure that it is **not** linked against.
    - Ensure that the framework target from the wrapper library is embedded into your application _only_.
    - Add all iOS 14 and above dependencies to this wrapper manually as cocoapods does not embed the binaries correctly.
    - Import all the required dependencies to the wrapper target and add `tokenCredential`, `callCompositeOptions`, and other initialization code to the top level class to launch the UI library.
    - Create the main entry point class. This could be a UIViewController for example, which loads up the `CallComposite`.
    - Set the top-level class as the `NSPrincipalClass` for the newly added wrapper framework.
    - If needed, the principal class could play define a shared protocol between the main target and the wrapper for additional control.

2. Drag the newly added framework into your main target's "Frameworks and Libraries" section with `Embed and Sign`.
3. In main app, use [`Loadable Bundles in Cocoa`](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingCode/Concepts/CocoaBundles.html#//apple_ref/doc/uid/20001269-BAJCIAHA) to load the UI library Wrapper only when iOS 14 or greater is available. Code example:

```Swift
if #available(iOS 14.0, *) {
    if let bundle = Bundle(path: Bundle.main.privateFrameworksPath!.appending("/<YOUR_FRAMEWORK_NAME>.framework")),
        let principalClass = bundle.principalClass as? UIViewController.Type {
        let controller = principalClass.init()
        self.addChild(controller)
        view.addSubview(controller.view)
    }
}
```

This method provides a way to load a framework into your application only if it is supported by the version of iOS.
