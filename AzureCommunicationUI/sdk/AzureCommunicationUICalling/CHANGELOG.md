# Release History
## 1.0.0-beta.2 (2022-06-07)
### New Features
- Implemented adaptive layout and tailored UX for iPad. [#221](https://github.com/Azure/communication-ui-library-ios/pull/221)
- Implemented new event to listen for remote participants joining a call [#209](https://github.com/Azure/communication-ui-library-ios/pull/209)
- Implemented new method `setRemoteParticipantViewData` to set ParticipantViewData for the remote participant. [#205](https://github.com/Azure/communication-ui-library-ios/pull/205)
- Implemented new behaviour for call denied to return to setup view. [#204](https://github.com/Azure/communication-ui-library-ios/pull/204)
- Implemented CallOnHold feature when there is audio session interruption. [#223](https://github.com/Azure/communication-ui-library-ios/pull/223)

### Breaking Changes
- Updated `setTarget(didFail:)` to `set(onErrorHandler:)`. [#227](https://github.com/Azure/communication-ui-library-ios/pull/227)
- Update `supportedLocales` to `getSupportedLocale` and move under `CallCompositeSupportedLocale`. [#214](https://github.com/Azure/communication-ui-library-ios/pull/214)
- Update `LocalizationConfiguration` to `LocalizationOptions`, and `ThemeConfiguration` to `ThemeOptions`. [#215](https://github.com/Azure/communication-ui-library-ios/pull/215)
- Add prefix for `CallCompositeSupportedLocale`, `CallCompositeErrorEvent` and `CallCompositeErrorCode`. [#216](https://github.com/Azure/communication-ui-library-ios/pull/216)
- Update `LocalSettings` to `LocalOptions`. [#226](https://github.com/Azure/communication-ui-library-ios/pull/226)
- Combined `GroupCallOptions` and `TeamsMeetingOptions` to `RemoteOptions`. [#229](https://github.com/Azure/communication-ui-library-ios/pull/229)
- Update `launch(with options:)` to `launch(remoteOptions:)`. [#229](https://github.com/Azure/communication-ui-library-ios/pull/229)

### Bugs Fixed
- Fixed drawer anchor when iPad change orientation [#206](https://github.com/Azure/communication-ui-library-ios/pull/206)
- Added speaking indication to VoiceOver for participant grid [#228](https://github.com/Azure/communication-ui-library-ios/pull/228)

### Other Changes
- Update the Manual Installation Instruction [#208](https://github.com/Azure/communication-ui-library-ios/pull/208)

## 1.0.0-beta.1 (2022-05-18)
This is the initial release of Azure Communication UI Calling Library. For more information, please see the [README](https://github.com/Azure/communication-ui-library-ios/blob/main/README.md) and [QuickStart](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/ui-library/get-started-call?tabs=kotlin&pivots=platform-ios).

This is a Public Preview version, so breaking changes are possible in subsequent releases as we improve the product. To provide feedback, please submit an issue in our [Issues](https://github.com/Azure/communication-ui-library-ios/issues).
