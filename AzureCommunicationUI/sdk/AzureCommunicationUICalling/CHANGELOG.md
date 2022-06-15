# Release History
## 1.0.0 (Upcoming)
### Bugs Fixed
- Fixed issue where header was still selectable with voiceover on and overlay visible. [#256](https://github.com/Azure/communication-ui-library-ios/pull/256)
- Fixed hold overlay to have a solid colour. [#262](https://github.com/Azure/communication-ui-library-ios/pull/262) 

## 1.0.0-beta.2 (2022-06-13)
### New Features
- Implemented adaptive layout and tailored UX for iPad. [#221](https://github.com/Azure/communication-ui-library-ios/pull/221)
- Implemented new event to listen for remote participants joining a call [#209](https://github.com/Azure/communication-ui-library-ios/pull/209)
- Implemented new method `set(remoteParticipantViewData:, for:, completionHandler:)` to set ParticipantViewData for the remote participant. [#205](https://github.com/Azure/communication-ui-library-ios/pull/205), [#212](https://github.com/Azure/communication-ui-library-ios/pull/212)
- Implemented new behaviour for call denied to return to setup view. [#204](https://github.com/Azure/communication-ui-library-ios/pull/204)
- Implemented CallOnHold feature when there is audio session interruption. [#223](https://github.com/Azure/communication-ui-library-ios/pull/223)

### Breaking Changes
- Updated `setTarget(didFail:)` function to `onError` property and moved to `CallComposite.Events`. [#227](https://github.com/Azure/communication-ui-library-ios/pull/227)
- Updated `supportedLocales` to `getSupportedLocale` and moved to `SupportedLocale`. [#214](https://github.com/Azure/communication-ui-library-ios/pull/214)
- Renamed `LocalizationConfiguration` to `LocalizationOptions`, and `ThemeConfiguration` to `ThemeOptions`. [#215](https://github.com/Azure/communication-ui-library-ios/pull/215)
- Added prefix for `CallCompositeError` and `CallCompositeErrorCode`. [#216](https://github.com/Azure/communication-ui-library-ios/pull/216)
- Renamed `LocalSettings` to `LocalOptions`. [#226](https://github.com/Azure/communication-ui-library-ios/pull/226)
- Combined `GroupCallOptions` and `TeamsMeetingOptions` to `RemoteOptions`. [#229](https://github.com/Azure/communication-ui-library-ios/pull/229)
- Renamed `launch(with options:)` to `launch(remoteOptions:)`. [#229](https://github.com/Azure/communication-ui-library-ios/pull/229)
- Updated `getSupportedLocales()` to `values`. [#240](https://github.com/Azure/communication-ui-library-ios/pull/240)

### Bugs Fixed
- Fixed drawer anchor when iPad change orientation [#206](https://github.com/Azure/communication-ui-library-ios/pull/206)
- Added speaking indication to VoiceOver for participant grid [#228](https://github.com/Azure/communication-ui-library-ios/pull/228)

### Other Changes
- Updated the Manual Installation Instruction [#208](https://github.com/Azure/communication-ui-library-ios/pull/208)

## 1.0.0-beta.1 (2022-05-18)
This is the initial release of Azure Communication UI Calling Library. For more information, please see the [README](https://github.com/Azure/communication-ui-library-ios/blob/main/README.md) and [QuickStart](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/ui-library/get-started-call?tabs=kotlin&pivots=platform-ios).

This is a Public Preview version, so breaking changes are possible in subsequent releases as we improve the product. To provide feedback, please submit an issue in our [Issues](https://github.com/Azure/communication-ui-library-ios/issues).
