# Release History

## 1.0.0-beta.2 (Upcoming)

### New Features
- Update joining experience in setup view. [#44](https://github.com/Azure/communication-ui-library-ios/pull/44)
- Support pinch & zoom, pan and double tap to zoom in screen share presentation. [#29](https://github.com/Azure/communication-ui-library-ios/pull/29)
- Update audio device selection list when connected to bluetooth/headphones. [#56](https://github.com/Azure/communication-ui-library-ios/pull/56)
### Breaking Changes

### Bug Fixes
- Cleaning up Calling State and Call Error when joining or returning to a call from error. [#28](https://github.com/Azure/communication-ui-library-ios/pull/28)
- Fix the order of CompositeError throwing in joining a call. [#11](https://github.com/Azure/communication-ui-library-ios/pull/11)
- Fix for info header doesn't disappear when bottom drawer is displayed. [#12](https://github.com/Azure/communication-ui-library-ios/pull/12)
- Fix for the local video rotation in setup view when device orientation is locked. [#13](https://github.com/Azure/communication-ui-library-ios/pull/13)
- Fix the display of the participant with an empty name in the participant list. [#24](https://github.com/Azure/communication-ui-library-ios/pull/24)
- Fix the default audio selection when the UI Composite is launched. [#21](https://github.com/Azure/communication-ui-library-ios/pull/21)
- Fixing consistency of unit test. [#35](https://github.com/Azure/communication-ui-library-ios/pull/35)
- Fixed the UX inconsistencies in the participant list to match Android.
- Fixed inconsistent display when dragging an opened participants list. [#49](https://github.com/Azure/communication-ui-library-ios/pull/49)
- Fixed SetupView in landscape mode and CallingView can't rotate to proper orientation after drawer being dismissed [#71](https://github.com/Azure/communication-ui-library-ios/pull/71)

### Other Changes
- Update Redux State when initializing the local video preview in the setup view. [#23](https://github.com/Azure/communication-ui-library-ios/pull/23)
- Remove alphabet in CFBundleShortVersionString and add UILibrarySemVersion inside info.plist. [#27](https://github.com/Azure/communication-ui-library-ios/pull/27)
- Update FluentUI version to 0.3.9 [#49](https://github.com/Azure/communication-ui-library-ios/pull/49)
- Code cleanup and refactoring.


## 1.0.0-beta.1 (2021-12-09)
This is the initial release of Azure Communication UI Library. For more information, please see the [README](README.md) and [QuickStart](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/ui-library/get-started-call?tabs=kotlin&pivots=platform-ios).

This is a Public Preview version, so breaking changes are possible in subsequent releases as we improve the product. To provide feedback, please submit an issue in our [Issues](https://github.com/Azure/communication-ui-library-ios/issues).
