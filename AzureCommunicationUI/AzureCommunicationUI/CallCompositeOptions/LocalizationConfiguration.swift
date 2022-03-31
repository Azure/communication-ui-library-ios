//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI

public struct LocalizationConfiguration {
    /// LanguageCode enum representing the locale code.
    public enum LanguageCode: String {
        /// German
        case deDE = "de"
        /// Japanese
        case jaJP = "ja"
        /// English
        case enUS = "en"
        /// Chinese (Traditional)
        case zhTW = "zh-Hant"
        /// Spanish
        case esES = "es"
        /// Chinese (Simplified)
        case zhCN = "zh-Hans"
        /// Italian
        case itIT = "it"
        /// English (United Kingdom)
        case enGB = "en-GB"
        /// Korean
        case koKR = "ko"
        /// Turkish
        case trTR = "tr"
        /// Russian
        case ruRU = "ru"
        /// French
        case frFR = "fr"
        /// Dutch
        case nlNL = "nl"
        /// Portuguese
        case ptPT = "pt"
    }

    let languageCode: String
    let localizableFilename: String
    let layoutDirection: LayoutDirection

    /// Creates an instance of `LocalizationConfiguration` with related parameters. Allow
    /// overriding strings of localization keys with Localizable.strings file or other localizable filename.
    /// - Parameter languageCode: String representing the language code (ie. en, fr, zh-Hant, zh-Hans, ...).
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

    /// Get supported languages the AzureCommunicationUICalling has predefined translations.
    /// - Returns: Get supported languages the AzureCommunicationUICalling
    ///  has predefined translations.
    public static var supportedLanguages: [String] {
        return Bundle(for: CallComposite.self).localizations
    }
}
