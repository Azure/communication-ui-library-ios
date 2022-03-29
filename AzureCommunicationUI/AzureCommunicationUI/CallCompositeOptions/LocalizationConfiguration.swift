//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI

public enum LanguageCode: Hashable {
    /// Custom value for unrecognized enum values
    case custom(String)
    /// German
    case de
    /// Japanese
    case ja
    /// English
    case en
    /// Chinese (Traditional)
    case zhHant
    /// Spanish
    case es
    /// Chinese (Simplified)
    case zhHans
    /// Italian
    case it
    /// English (United Kingdom)
    case enGB
    /// Korean
    case ko
    /// Turkish
    case tr
    /// Russian
    case ru
    /// French
    case fr
    /// Dutch
    case nl
    /// Portuguese
    case pt

    /// Creates an instance of `LanguageCode` with for language code.
    /// - Parameter rawValue: String representing the locale code (ie. en, fr,  zh-Hant, zh-Hans, ...).
    ///  If unsupported language is provided will create LanguageCode as`.custom(rawValue)`.
    public init(rawValue: String) {
        switch rawValue {
        case "de":
            self = .de
        case "ja":
            self = .ja
        case "en":
            self = .en
        case "zh-Hant":
            self = .zhHant
        case "es":
            self = .es
        case "zh-Hans":
            self = .zhHans
        case "it":
            self = .it
        case "en-GB":
            self = .enGB
        case "ko":
            self = .ko
        case "tr":
            self = .tr
        case "ru":
            self = .ru
        case "fr":
            self = .fr
        case "nl":
            self = .nl
        case "pt":
            self = .pt
        default:
            self = .custom(rawValue)
        }
    }

    /// Get string representing the LanguageCode (ie. en, fr,  zh-Hant, zh-Hans, ...).
    public var rawValue: String {
        switch self {
        case let .custom(language):
            return language
        case .de:
            return "de"
        case .ja:
            return "ja"
        case .en:
            return "en"
        case .zhHant:
            return "zh-Hant"
        case .es:
            return "es"
        case .zhHans:
            return "zh-Hans"
        case .it:
            return "it"
        case .enGB:
            return "en-GB"
        case .ko:
            return "ko"
        case .tr:
            return "tr"
        case .ru:
            return "ru"
        case .fr:
            return "fr"
        case .nl:
            return "nl"
        case .pt:
            return "pt"
        }
    }
}

public struct LocalizationConfiguration {
    let languageCode: LanguageCode
    let localizableFilename: String
    let layoutDirection: LayoutDirection

    /// Creates an instance of `LocalizationConfiguration` with related parameters. Allow
    /// overriding strings of localization keys with Localizable.strings file or other localizable filename.
    /// - Parameter languageCode: String representing the locale code (ie. en, fr, zh-Hant, zh-Hans, ...).
    /// - Parameter localizableFilename: Filename of the `.strings` file to override predefined
    ///  Call Composite's localization key or to provide translation for an custom language.
    ///  The keys of the string should match with the keys from AzureCommunicationUI
    ///  localization keys. Default value is `"Localizable"`.
    /// - Parameter layoutDirection: LayoutDirection for mirroring layout for right-to-left.
    ///  Default value is `false`.
    public init(languageCode: LanguageCode,
                localizableFilename: String = "Localizable",
                layoutDirection: LayoutDirection = .leftToRight) {
        self.languageCode = languageCode
        self.localizableFilename = localizableFilename
        self.layoutDirection = layoutDirection
    }

    /// Get supported languages the AzureCommunicationUICalling has predefined translations.
    /// - Returns: Get supported languages the AzureCommunicationUICalling
    ///  has predefined translations.
    public static var supportedLanguages: [LanguageCode] {
        return [.de, .ja, .en, .zhHant, .es, .zhHans, .it, .enGB, .ko, .tr, .ru, .fr, .nl, .pt]
    }
}
