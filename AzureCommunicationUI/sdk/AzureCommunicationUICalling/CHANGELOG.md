# Azure Communication UI Calling Release History
## 1.14.1 (2025-05-02)

### Bugfixes
- Xcode 16.3 compiling issue

## 1.14.0 (2025-04-17)

### Features
- Real Time Text Support

## 1.14.0-beta.3 (2025-04-11)

### Bugfixes
- Fix microphone permission in fresh install

## 1.14.0-beta.2 (2025-04-10)

### Bugfixes
- Accessibility bugfix

## 1.14.0-beta.1 (2025-01-15)

### Features
- Real Time Text Support

## 1.13.0 (2024-12-04)

### Features
- Call screen header custom button

### Bugfixes
- iOS18 and Xcode 16 bugfixes 

## 1.12.0 (2024-10-31)

### Features
- Color theming support for button font color.
- Update min support version to iOS 16.
- Video displays in the Picture-in-Picture when application is in background mode.

## 1.12.0-beta.1 (2024-10-10)

### Features
- Call screen header custom button
- Color theming support

## 1.11.0 (2024-09-25)

### Features
- Call screen information header title/subtitle customization
- Ability to hide or disable buttons and create custom buttons

### Bugfixes
- Camera button doesn't work on the Setup screen when the internet is off
- On hold title is not centred in some conditions
- Some labels not announces correctly via accessibility
- Xcode 16 build issue

## 1.11.0-beta.2 (2024-09-11)

### Features
- Call screen information header title/subtitle customization
- Ability to hide or disable buttons and create custom buttons

### Bugfixes
- Camera button doesn't work on the Setup screen when the internet is off
- On hold title is not centred in some conditions
- Some labels not announces correctly via accessibility

# 1.11.0-beta.1 (2024-08-28)
### Features
- Call screen control bar custom button support


## 1.10.0 (2024-08-14)

### Features
- Captions support

## 1.9.0 (2024-06-27)

### Features
- Rooms call


## 1.8.0 (2024-05-20)

### Features

- 1 to N Calling with push notification support
- CallKit Integration
- Teams meeting join with meeting id

## 1.7.0 (2024-05-29)

### Features
- Disable leave call confirmation dialog
- Teams meeting short URL support

## 1.6.1 (2024-04-01)

### Bug Fixes
- Accessibility bugs fixed for announcement for mic button, camera button, resume button, participant information
- Accessibility bugs fixed for keyboard focus on device select button, more button, leave call button, participant button
- Accessibility bugs fixed for camera smart invert

## 1.6.0 (2024-03-04)

### Features
- Audio Only Mode
- Enhanced Supportability
- Multitasking with Picture-in-Picture support
- Admit lobby users

## 1.5.0 (2023-12-04)

### Features
- User facing diagnostics

### Bug Fixes
- Hide lobby users in GridView and Participant List

## 1.4.0 (2023-08-30)

### Features
- Use Dominant Speakers feature to determine which remove participants to display on the grid when number of participants more then 6.
- Introducing call state changed event for `CallComposite.events.onCallStateChanged`.
- Introducing ability to dismiss call composite `CallComposite.dismiss()` and be notified when it's dismissed `CallComposite.events.onDismissed`.
- Configure orientation for setup screen and call screen `CallCompositeOptions(..., setupScreenOrientation, callingScreenOrientation)`.

## 1.3.1 (2023-07-19)
### Bugs Fixed
- Call join being blocked when microphone is unavailable to use for UI Composite at the moment
- Call Resume and join on hold checks microphone available
- Call join when network is gained after it is lost bug fixed

## 1.4.0-beta.1 (2023-04-26)
### New Features
- Introduced dominant speaker into calling grid view to determine the participants order on the screen of grid view. [667](https://github.com/Azure/communication-ui-library-ios/pull/667)

## 1.3.0 (2023-04-06)
### New Features
- `LocalOptions(skipSetupScreen: Bool?)` to skip the setup screen and directly join the call. [642](https://github.com/Azure/communication-ui-library-ios/pull/642)
- `LocalOptions(cameraOn: Bool?, microphoneOn: Bool?)` to setup the default behaviour. [642](https://github.com/Azure/communication-ui-library-ios/pull/642)

## 1.2.0 (2023-03-09)
### New Features
- Introduced a Call History available with `DebugInfo` on the `CallComposite` [610](https://github.com/Azure/communication-ui-library-ios/pull/610)

## 1.2.0-beta.1 (2022-12-14)
### New Features
- Introduced `DebugInfo` to get debug information for `CallComposite` [#446](https://github.com/Azure/communication-ui-library-ios/pull/446), [#476](https://github.com/Azure/communication-ui-library-ios/pull/476)
- Additional localization support for 6 languages (Arabic, Finnish, Hebrew, Norwegian Bokmål, Polish, Swedish) [#484](https://github.com/Azure/communication-ui-library-ios/pull/484)

## 1.1.0 (2022-11-09)
### New Features
- Implemented new feature where local user would be removed from the participant list when the app is terminated [#352](https://github.com/Azure/communication-ui-library-ios/pull/352)
- Added aadToken for getting the ACS token in joining a call [#380](https://github.com/Azure/communication-ui-library-ios/pull/380)

### Breaking Changes
- Changed callEnd error inside CallCompositeError from mutable to inmutable [#364](https://github.com/Azure/communication-ui-library-ios/pull/364)

### Bugs Fixed
- Fixed rotation does not work until drawer opens on iOS 16 [#363](https://github.com/Azure/communication-ui-library-ios/pull/363)
- Fixed timer resources deallocation when a user leaves and rejoins a call quickly [#365](https://github.com/Azure/communication-ui-library-ios/pull/365)
- Fixed end call animation in landscape mode is not slide off the bottom of the screen correctly [#376](https://github.com/Azure/communication-ui-library-ios/pull/376)
- Fixed end call drawer title misalignment in landscape mode [#378](https://github.com/Azure/communication-ui-library-ios/pull/378)
- Fixed remote participants do not see my video stream after resuming my call [#383](https://github.com/Azure/communication-ui-library-ios/pull/383)
- Fixed drawer being cutoff in large font size and its animation [#384](https://github.com/Azure/communication-ui-library-ios/pull/384)
- Fixed issue with call on hold video not showing up for remote user when resuming 
    [#414](https://github.com/Azure/communication-ui-library-ios/pull/414)
- Fixed failure to grab ownership of microphone from other audio app [#423](https://github.com/Azure/communication-ui-library-ios/pull/423)

### Other Changes
- Updated CallingSDK's version to GA in manual installation guide [#435](https://github.com/Azure/communication-ui-library-ios/pull/435)

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
