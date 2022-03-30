**ENUM**

# `LanguageCode`

```swift
public enum LanguageCode: Hashable
```

## Description

LanguageCode enum representing the locale code. Currently supports the following languages:
|         Language         | LanguageCode (enum) | languageCode |
|:------------------------:|:-------------------:|:------------:|
|          German          |         deDE        |      de      |
|         Japanese         |         JaJP        |      ja      |
|          English         |         enUS        |      en      |
|   Chinese (Traditional)  |         zhTW        |    zh-Hant   |
|          Spanish         |         esES        |      es      |
|   Chinese (Simplified)   |         zhCN        |    zh-Hans   |
|          Italian         |         itIT        |      it      |
| English (United Kingdom) |         enGB        |     en-GB    |
|          Korean          |         koKR        |      ko      |
|          Turkish         |         trTr        |      tr      |
|          Russian         |         ruRu        |      ru      |
|          French          |         frFR        |      fr      |
|           Dutch          |         nlNL        |      nl      |
|        Portuguese        |         ptPT        |      pt      |

## Declaration

### `init`

Creates an instance of `LanguageCode` with for language code.

```swift
public init(rawValue: String)
```

### Parameters
* `rawValue` - String representing the locale code (ie. en, fr,  zh-Hant, zh-Hans, ...). If unsupported language is provided will create `.custom(rawValue)`.

### `custom(_:)`

Creates an instance of `LanguageCode` with for language code for an unsupported language. Need to provide key-value translation in `Localizable.strings` (or other filename), if a key is not found the text will fallback to English as default.

```swift
custom(_:)
```

### Parameters
* `_` - String representing the unsupported locale code (ie. en, fr,  zh-Hant, zh-Hans, ...).


## Properties
### `rawValue`

Get string representing the LanguageCode (ie. en, fr,  zh-Hant, zh-Hans, ...).

```swift
public var rawValue: String
```