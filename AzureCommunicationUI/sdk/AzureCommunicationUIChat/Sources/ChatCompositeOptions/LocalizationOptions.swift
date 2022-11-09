//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI

/// SupportedLocale representing the supported locales.
struct SupportedLocale {
    /// Chinese, Simplified
    static let zh = Locale(identifier: "zh")
    /// Chinese, Simplified
    static let zhHans = Locale(identifier: "zh-Hans")
    /// Chinese, Simplified (China mainland)
    static let zhHansCN = Locale(identifier: "zh-Hans-CN")
    /// Chinese, Traditional
    static let zhHant = Locale(identifier: "zh-Hant")
    /// Chinese, Traditional (Taiwan)
    static let zhHantTW = Locale(identifier: "zh-Hant-TW")
    /// Dutch
    static let nl = Locale(identifier: "nl")
    /// Dutch (Netherlands)
    static let nlNL = Locale(identifier: "nl-NL")
    /// English
    static let en = Locale(identifier: "en")
    /// English (United Kingdom)
    static let enGB = Locale(identifier: "en-GB")
    /// English (United States)
    static let enUS = Locale(identifier: "en-US")
    /// French
    static let fr = Locale(identifier: "fr")
    /// French (France)
    static let frFR = Locale(identifier: "fr-FR")
    /// German
    static let de = Locale(identifier: "de")
    /// German (Germany)
    static let deDE = Locale(identifier: "de-DE")
    /// Italian
    static let it = Locale(identifier: "it")
    /// Italian (Italy)
    static let itIT = Locale(identifier: "it-IT")
    /// Japanese
    static let ja = Locale(identifier: "ja")
    /// Japanese (Japan)
    static let jaJP = Locale(identifier: "ja-JP")
    /// Korean
    static let ko = Locale(identifier: "ko")
    /// Korean (South Korea)
    static let koKR = Locale(identifier: "ko-KR")
    /// Portuguese
    static let pt = Locale(identifier: "pt")
    /// Portuguese (Brazil)
    static let ptBR = Locale(identifier: "pt-BR")
    /// Russian
    static let ru = Locale(identifier: "ru")
    /// Russian (Russia)
    static let ruRU = Locale(identifier: "ru-RU")
    /// Spanish
    static let es = Locale(identifier: "es")
    /// Spanish (Spain)
    static let esES = Locale(identifier: "es-ES")
    /// Turkish
    static let tr = Locale(identifier: "tr")
    /// Turkish (Turkey)
    static let trTR = Locale(identifier: "tr-TR")

    /// Get supported locales the AzureCommunicationUIChat has predefined translations.
    /// - Returns: Get supported Locales the AzureCommunicationUIChat
    ///  has predefined translations.
    static var values: [Locale] {
        return Bundle(for: ChatComposite.self).localizations.sorted()
            .map { Locale(identifier: $0) }
    }
}

/// Options to allow customizing localization.
struct LocalizationOptions {
    let languageCode: String
    let localizableFilename: String
    let layoutDirection: LayoutDirection

    /// Creates an instance of `LocalizationOptions` with related parameters. Allow
    /// overriding strings of localization keys with Localizable.strings file or other localizable filename.
    /// - Parameter locale: Locale struct representing the language identifier (ie. en, fr, fr-FR,
    /// zh-Hant, zh-Hans, ...), with or without region. If Locale identifier is not valid, will default to `en`.
    /// - Parameter localizableFilename: Filename of the `.strings` file to override predefined
    ///  Chat Composite's localization key or to provide translation for an custom language.
    ///  The keys of the string should match with the keys from AzureCommunicationUI
    ///  localization keys. Default value is `"Localizable"`.
    /// - Parameter layoutDirection: LayoutDirection for mirroring layout for right-to-left.
    ///  Default value is `false`.
    init(locale: Locale,
         localizableFilename: String = "Localizable",
         layoutDirection: LayoutDirection = .leftToRight) {
        self.languageCode = locale.collatorIdentifier ?? "en"
        self.localizableFilename = localizableFilename
        self.layoutDirection = layoutDirection
    }
}
