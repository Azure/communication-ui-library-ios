# Release History
## 1.0.0-beta.3 (Upcoming)
### New Features
- Updated minimum iOS version to 14.0. [#103](https://github.com/Azure/communication-ui-library-ios/pull/103)
- Updated leave call confirmation drawer. [#129](https://github.com/Azure/communication-ui-library-ios/pull/129)
- Implemented new local participant avatar parameter into launch method. [#131](https://github.com/Azure/communication-ui-library-ios/pull/131)
- Implemented automatic system language detection for localization. [#126](https://github.com/Azure/communication-ui-library-ios/pull/126)
- Updated localization language code to supoort both `ll` (language code) and `ll-CC` (language code with country code) format. [#133](https://github.com/Azure/communication-ui-library-ios/pull/133)
- Implemented additional initializer for `LocalizationConfiguration` to accept Locale struct. [#133](https://github.com/Azure/communication-ui-library-ios/pull/133)


### Bugs Fixed
- Fixed screen share not rendering in large screen device. [#128](https://github.com/Azure/communication-ui-library-ios/pull/128)

## 1.0.0-beta.2 (2022-04-04)
### New Features
- Updated joining experience in setup view. [#44](https://github.com/Azure/communication-ui-library-ios/pull/44)
- Implemented pinch & zoom, pan and double tap to zoom in screen share presentation. [#29](https://github.com/Azure/communication-ui-library-ios/pull/29)
- Updated audio device selection list when connected to bluetooth/headphones. [#56](https://github.com/Azure/communication-ui-library-ios/pull/56)
- Implemented Localization support for 13 languages and right-to-left mirror layout. [#73](https://github.com/Azure/communication-ui-library-ios/pull/73) 
 
### Breaking Changes
- Renamed `ErrorType` to `CommunicationUIErrorType`. [#99](https://github.com/Azure/communication-ui-library-ios/pull/99)
- Renamed parameter `communicationTokenCredential` to `credential` in both `GroupCallOptions` and `TeamsMeetingOptions` initializers. [#99](https://github.com/Azure/communication-ui-library-ios/pull/99)
- Renamed `themeConfiguration` to `theme` in `CallCompositeOptions` initializer. [#99](https://github.com/Azure/communication-ui-library-ios/pull/99)

### Bugs Fixed
- Cleaned up Calling State and Call Error when joining or returning to a call from error. [#28](https://github.com/Azure/communication-ui-library-ios/pull/28)
- Fixed the order of CompositeError throwing in joining a call. [#11](https://github.com/Azure/communication-ui-library-ios/pull/11)
- Fixed for info header doesn't disappear when bottom drawer is displayed. [#12](https://github.com/Azure/communication-ui-library-ios/pull/12)
- Fixed for the local video rotation in setup view when device orientation is locked. [#13](https://github.com/Azure/communication-ui-library-ios/pull/13)
- Fixed the display of the participant with an empty name in the participant list. [#24](https://github.com/Azure/communication-ui-library-ios/pull/24)
- Fixed the default audio selection when the UI Composite is launched. [#21](https://github.com/Azure/communication-ui-library-ios/pull/21)
- Fixed consistency of unit test. [#35](https://github.com/Azure/communication-ui-library-ios/pull/35)
- Fixed the UX inconsistencies in the participant list to match Android.
- Fixed inconsistent display when dragging an opened participants list. [#49](https://github.com/Azure/communication-ui-library-ios/pull/49)
- Fixed SetupView in landscape mode and CallingView can't rotate to proper orientation after drawer being dismissed [#71](https://github.com/Azure/communication-ui-library-ios/pull/71)

### Other Changes
- Updated Redux State when initializing the local video preview in the setup view. [#23](https://github.com/Azure/communication-ui-library-ios/pull/23)
- Removed alphabet in CFBundleShortVersionString and add UILibrarySemVersion inside info.plist. [#27](https://github.com/Azure/communication-ui-library-ios/pull/27)
- Updated FluentUI version to 0.3.9 [#49](https://github.com/Azure/communication-ui-library-ios/pull/49)
- Code cleanup and refactoring.


## 1.0.0-beta.1 (2021-12-09)
This is the initial release of Azure Communication UI Library. For more information, please see the [README](README.md) and [QuickStart](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/ui-library/get-started-call?tabs=kotlin&pivots=platform-ios).

This is a Public Preview version, so breaking changes are possible in subsequent releases as we improve the product. To provide feedback, please submit an issue in our [Issues](https://github.com/Azure/communication-ui-library-ios/issues).
