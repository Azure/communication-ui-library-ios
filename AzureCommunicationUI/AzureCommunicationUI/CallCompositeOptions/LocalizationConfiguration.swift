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
    case deDE
    /// Japanese
    case jaJP
    /// English
    case enUS
    /// Chinese (Traditional)
    case zhTW
    /// Spanish
    case esES
    /// Chinese (Simplified)
    case zhCN
    /// Italian
    case itIT
    /// English (United Kingdom)
    case enGB
    /// Korean
    case koKR
    /// Turkish
    case trTR
    /// Russian
    case ruRU
    /// French
    case frFR
    /// Dutch
    case nlNL
    /// Portuguese
    case ptPT

    /// Creates an instance of `LanguageCode` with for language code.
    /// - Parameter rawValue: String representing the locale code (ie. en, fr,  zh-Hant, zh-Hans, ...).
    ///  If unsupported language is provided will create LanguageCode as`.custom(rawValue)`.
    public init(rawValue: String) {
        switch rawValue {
        case "de":
            self = .deDE
        case "ja":
            self = .jaJP
        case "en":
            self = .enUS
        case "zh-Hant":
            self = .zhTW
        case "es":
            self = .esES
        case "zh-Hans":
            self = .zhCN
        case "it":
            self = .itIT
        case "en-GB":
            self = .enGB
        case "ko":
            self = .koKR
        case "tr":
            self = .trTR
        case "ru":
            self = .ruRU
        case "fr":
            self = .frFR
        case "nl":
            self = .nlNL
        case "pt":
            self = .ptPT
        default:
            self = .custom(rawValue)
        }
    }

    /// Get string representing the LanguageCode (ie. en, fr,  zh-Hant, zh-Hans, ...).
    public var rawValue: String {
        switch self {
        case let .custom(language):
            return language
        case .deDE:
            return "de"
        case .jaJP:
            return "ja"
        case .enUS:
            return "en"
        case .zhTW:
            return "zh-Hant"
        case .esES:
            return "es"
        case .zhCN:
            return "zh-Hans"
        case .itIT:
            return "it"
        case .enGB:
            return "en-GB"
        case .koKR:
            return "ko"
        case .trTR:
            return "tr"
        case .ruRU:
            return "ru"
        case .frFR:
            return "fr"
        case .nlNL:
            return "nl"
        case .ptPT:
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
        return [
            .deDE,
            .jaJP,
            .enUS,
            .zhTW,
            .esES,
            .zhCN,
            .itIT,
            .enGB,
            .koKR,
            .trTR,
            .ruRU,
            .frFR,
            .nlNL,
            .ptPT
        ]
    }
}
