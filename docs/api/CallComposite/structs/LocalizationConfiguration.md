**STRUCT**

# `LocalizationConfiguration`

```swift
public struct LocalizationConfiguration
```

## Description

A configuration to allow customizing localization.

## Methods

### `init`

Creates an instance of `LocalizationConfiguration` with related parameters. Allow overriding strings of [localization keys](../../../../AzureCommunicationUI/AzureCommunicationUI/Localization/en.lproj/Localizable.strings) with Localizable.strings file or other localizable filename.

```swift
public init(
    languageCode: String,
    localizableFilename: String = "Localizable",
    isRightToLeft: Bool = false)
```

### Parameters
* `languageCode` - String representing the language code (ie. en, fr,  zh-Hant, zh-Hans, ...).
* `localizableFilename` - Filename of the `.strings` file to override predefined Call Composite's localization key or to provide translation for an custom language. The keys of the string should match with the keys from AzureCommunicationUI [localization keys](../../../../AzureCommunicationUI/AzureCommunicationUI/Localization/en.lproj/Localizable.strings). Default value is `""`.
* `isRightToLeft` - Boolean for mirroring layout for right-to-left. Default value is `false`.

## Properties
### `supportedLanguages`

Get supported languages the AzureCommunicationUICalling has predefined translations. A list of language names for the locale codes that has predefined translation strings.

```swift
public static var supportedLanguages: [String]
```