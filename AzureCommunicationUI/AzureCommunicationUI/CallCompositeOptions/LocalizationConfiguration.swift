//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI

public enum LanguageCode: CustomStringConvertible, Hashable {
    case custom(String)
    case de
    case ja
    case en
    case zhHant
    case es
    case zhHans
    case it
    case enGB
    case ko
    case tr
    case ru
    case fr
    case nl
    case pt

    public var description: String {
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
    let customTranslations: [String: String]
    let layoutDirection: LayoutDirection

    /// Creates an instance of `LocalizationConfiguration` with related parameters. Allow
    /// overriding strings of localization keys with Localizable.strings file or other localizable filename.
    /// - Parameter languageCode: String representing the locale code (ie. en, fr, zh-Hant, zh-Hans, ...).
    /// - Parameter localizableFilename: Filename of the `.strings` file to override predefined
    ///  Call Composite's localization key or to provide translation for an custom language.
    ///  The keys of the string should match with the keys from AzureCommunicationUI
    ///  localization keys. Default value is `""`.
    /// - Parameter layoutDirection: LayoutDirection for mirroring layout for right-to-left.
    ///  Default value is `false`.
    public init(languageCode: LanguageCode,
                localizableFilename: String = "",
                layoutDirection: LayoutDirection = .leftToRight) {
        self.languageCode = languageCode
        self.localizableFilename = localizableFilename
        self.customTranslations = [:]
        self.layoutDirection = layoutDirection
    }

    /// Creates an instance of `LocalizationConfiguration` with related parameters. Allow
    /// overriding strings of localization keys with dictionary.
    /// - Parameter languageCode: String representing the locale code (ie. en, fr, zh-Hant, zh-Hans, ...).
    /// - Parameter customTranslations: A dictionary of key-value pairs to override
    ///  predefined AzureCommunicationUICalling's localization string. The keys of the string
    ///  should match with the keys from AzureCommunicationUI localization keys.
    /// - Parameter isRightToLeft: LayoutDirection for mirroring layout for right-to-left.
    ///  Default value is `false`.
    public init(languageCode: LanguageCode,
                customTranslations: [String: String],
                layoutDirection: LayoutDirection = .leftToRight) {
        self.languageCode = languageCode
        self.localizableFilename = ""
        self.customTranslations = customTranslations
        self.layoutDirection = layoutDirection
    }

    /// Get supported languages the AzureCommunicationUICalling has predefined translations.
    /// - Returns: Get supported languages the AzureCommunicationUICalling
    ///  has predefined translations.
    public static var supportedLanguages: [LanguageCode] {
        return [.de, .ja, .en, .zhHant, .es, .zhHans, .it, .enGB, .ko, .tr, .ru, .fr, .nl, .pt]
    }
}
