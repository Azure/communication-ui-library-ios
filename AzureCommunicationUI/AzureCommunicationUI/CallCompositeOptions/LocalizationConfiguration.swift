//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI

/// A configuration to allow customizing localization.
public struct LocalizationConfiguration {
    /// LanguageCode enum representing the locale code.
    public enum LanguageCode: String {
        /// Chinese, Simplified
        case zh = "zh"
        /// Chinese, Simplified
        case zhHans = "zh-Hans"
        /// Chinese, Simplified (China mainland)
        case zhHansCN = "zh-Hans-CN"
        /// Chinese, Traditional
        case zhHant = "zh-Hant"
        /// Chinese, Traditional (Taiwan)
        case zhHantTW = "zh-Hant-TW"
        /// Dutch
        case nl = "nl"
        /// Dutch (Netherlands)
        case nlNL = "nl-NL"
        /// English
        case en = "en"
        /// English (United Kingdom)
        case enGB = "en-GB"
        /// English (United States)
        case enUS = "en-US"
        /// French
        case fr = "fr"
        /// French (France)
        case frFR = "fr-FR"
        /// German
        case de = "de"
        /// German (Germany)
        case deDE = "de-DE"
        /// Italian
        case it = "it"
        /// Italian (Italy)
        case itIT = "it-IT"
        /// Japanese
        case ja = "ja"
        /// Japanese (Japan)
        case jaJP = "ja-JP"
        /// Korean
        case ko = "ko"
        /// Korean (South Korea)
        case koKR = "ko-KR"
        /// Portuguese
        case pt = "pt"
        /// Portuguese (Brazil)
        case ptBR = "pt-BR"
        /// Russian
        case ru = "ru"
        /// Russian (Russia)
        case ruRU = "ru-RU"
        /// Spanish
        case es = "es"
        /// Spanish (Spain)
        case esES = "es-ES"
        /// Turkish
        case tr = "tr"
        /// Turkish (Turkey)
        case trTR = "tr-TR"
    }

    let languageCode: String
    let localizableFilename: String
    let layoutDirection: LayoutDirection

    /// Creates an instance of `LocalizationConfiguration` with related parameters. Allow
    /// overriding strings of localization keys with Localizable.strings file or other localizable filename.
    /// - Parameter languageCode: String representing the language code with or without region (ie. en, fr, fr-FR, zh-Hant, zh-Hans, ...)  separated by dash `-`.
    /// - Parameter localizableFilename: Filename of the `.strings` file to override predefined
    ///  Call Composite's localization key or to provide translation for an custom language.
    ///  The keys of the string should match with the keys from AzureCommunicationUI
    ///  localization keys. Default value is `"Localizable"`.
    /// - Parameter layoutDirection: LayoutDirection for mirroring layout for right-to-left.
    ///  Default value is `false`.
    public init(languageCode: String,
                localizableFilename: String = "Localizable",
                layoutDirection: LayoutDirection = .leftToRight) {
        self.languageCode = languageCode
        self.localizableFilename = localizableFilename
        self.layoutDirection = layoutDirection
    }

    /// Creates an instance of `LocalizationConfiguration` with related parameters. Allow
    /// overriding strings of localization keys with Localizable.strings file or other localizable filename.
    /// - Parameter locale: Locale struct representing the language identifier (ie. en, fr, fr-FR, zh-Hant, zh-Hans, ...), with or without region. If Locale.languageCode is nil, will default to `en`.
    /// - Parameter localizableFilename: Filename of the `.strings` file to override predefined
    ///  Call Composite's localization key or to provide translation for an custom language.
    ///  The keys of the string should match with the keys from AzureCommunicationUI
    ///  localization keys. Default value is `"Localizable"`.
    /// - Parameter layoutDirection: LayoutDirection for mirroring layout for right-to-left.
    ///  Default value is `false`.
    public init(locale: Locale,
                localizableFilename: String = "Localizable",
                layoutDirection: LayoutDirection = .leftToRight) {
        self.languageCode = locale.collatorIdentifier ?? "en"
        self.localizableFilename = localizableFilename
        self.layoutDirection = layoutDirection
    }

    /// Get supported languages the AzureCommunicationUICalling has predefined translations.
    /// - Returns: Get supported languages the AzureCommunicationUICalling
    ///  has predefined translations.
    public static var supportedLanguages: [String] {
        return Bundle(for: CallComposite.self).localizations
    }
}
