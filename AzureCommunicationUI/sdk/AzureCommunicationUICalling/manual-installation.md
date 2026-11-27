# Local Package Installation

You can add the UI Library from a local copy of the repository instead of resolving it from GitHub, for example to debug the library or to try unreleased changes.

## Steps

1. Clone (or add as a git submodule) [`communication-ui-library-ios`](https://github.com/Azure/communication-ui-library-ios) and check out the release tag you need.
2. Open your app's Xcode project or workspace.
3. Choose **File > Add Package Dependencies...**, select **Add Local...**, and select the root folder of the cloned repository (the folder that contains `Package.swift`).
4. Add the `AzureCommunicationUICalling` product to your app target in the **Frameworks, Libraries, and Embedded Content** section.
5. `import AzureCommunicationUICalling` in your code.

Xcode resolves the library's dependencies (AzureCommunicationCalling, AzureCommunicationCommon, AzureCore and FluentUI) with Swift Package Manager, so you don't need to add them manually.

If your app manifest is a `Package.swift`, use a path dependency instead:

```swift
.package(path: "../communication-ui-library-ios")
```
