# Azure Communication UI Calling Release History

## 1.1.0-beta.1 (2022-10-03)
### New Features
- Implemented new error message `cameraFailure` that can be sent to developers when:
    - turning on camera fails. [#311](https://github.com/Azure/communication-ui-library-ios/pull/311)
    - in rare cases device manager throws an error [#301](https://github.com/Azure/communication-ui-library-ios/pull/301) [#334](https://github.com/Azure/communication-ui-library-ios/pull/334)
    
- Introduced NavigationBarViewData as a new local launch option to customize title and subtitle in set up view. [#309](https://github.com/Azure/communication-ui-library-ios/pull/309)
- An alert would now be shown when joining the call with no active network connection [#328](https://github.com/Azure/communication-ui-library-ios/pull/328)
- A new link to system settings was added to change camera and video permission directly [313](https://github.com/Azure/communication-ui-library-ios/pull/313)

### Bugs Fixed
- Fixed an issue where demo app's settings page can't be dismissed in landscape mode. [#280](https://github.com/Azure/communication-ui-library-ios/pull/280)
- Fixed an issue where speaking overlay custom colour not showing up properly [#281](https://github.com/Azure/communication-ui-library-ios/pull/281)
- Fixed an issue where participant drawer height not calculated correctly [#297](https://github.com/Azure/communication-ui-library-ios/pull/297)
- Fixed an issue where InfoHeaderView not showing up when VoiceOver is on [#296](https://github.com/Azure/communication-ui-library-ios/pull/296)
- Fixed an issue where RTL layout might not being rendered properly in demo app [#319](https://github.com/Azure/communication-ui-library-ios/pull/319)
- Fixed an issue where text label being cutoff when accessibility large font feature is enabled [#308](https://github.com/Azure/communication-ui-library-ios/pull/308)
- Fixed an issue where contrast ratio of some labels/icons being too low for visually impaired users [#305](https://github.com/Azure/communication-ui-library-ios/pull/305)
- Fixed an issue where InfoHeaderView doesn't support large front size text [#331](https://github.com/Azure/communication-ui-library-ios/pull/331)
- Fixed an issue where there was no accessibility label for the participants button [#345](https://github.com/Azure/communication-ui-library-ios/pull/345)

### Other Changes
- Updated CallingSDK's version to GA in manual installation guide [#298](https://github.com/Azure/communication-ui-library-ios/pull/298)
- Updated the design of error banners ("Snackbar") by adapting the latest FluentUI colours. [#314](https://github.com/Azure/communication-ui-library-ios/pull/314)

## 1.0.0 (2022-06-21)
### Bugs Fixed
- Fixed issue where header was still selectable with voiceover on and overlay visible. [#256](https://github.com/Azure/communication-ui-library-ios/pull/256)
- Fixed hold overlay to have a solid colour. [#262](https://github.com/Azure/communication-ui-library-ios/pull/262)
- Fixed the issue that resume a call without internet could stop user from exit. [#268](https://github.com/Azure/communication-ui-library-ios/pull/268)
- Fixed issue inconsistent camera state is inconsistent in setup view when being denied to or evicted from a call. [#273](https://github.com/Azure/communication-ui-library-ios/pull/273)

### Other Changes
- Added delay for camera status update. [#270](https://github.com/Azure/communication-ui-library-ios/pull/270)

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
