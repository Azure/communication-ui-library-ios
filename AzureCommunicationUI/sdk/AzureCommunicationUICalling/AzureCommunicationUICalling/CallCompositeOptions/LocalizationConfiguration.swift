//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI

/// CallCompositeSupportedLocale representing the supported locales.
public struct CallCompositeSupportedLocale {
    /// Chinese, Simplified
    public static let zh = Locale(identifier: "zh")
    /// Chinese, Simplified
    public static let zhHans = Locale(identifier: "zh-Hans")
    /// Chinese, Simplified (China mainland)
    public static let zhHansCN = Locale(identifier: "zh-Hans-CN")
    /// Chinese, Traditional
    public static let zhHant = Locale(identifier: "zh-Hant")
    /// Chinese, Traditional (Taiwan)
    public static let zhHantTW = Locale(identifier: "zh-Hant-TW")
    /// Dutch
    public static let nl = Locale(identifier: "nl")
    /// Dutch (Netherlands)
    public static let nlNL = Locale(identifier: "nl-NL")
    /// English
    public static let en = Locale(identifier: "en")
    /// English (United Kingdom)
    public static let enGB = Locale(identifier: "en-GB")
    /// English (United States)
    public static let enUS = Locale(identifier: "en-US")
    /// French
    public static let fr = Locale(identifier: "fr")
    /// French (France)
    public static let frFR = Locale(identifier: "fr-FR")
    /// German
    public static let de = Locale(identifier: "de")
    /// German (Germany)
    public static let deDE = Locale(identifier: "de-DE")
    /// Italian
    public static let it = Locale(identifier: "it")
    /// Italian (Italy)
    public static let itIT = Locale(identifier: "it-IT")
    /// Japanese
    public static let ja = Locale(identifier: "ja")
    /// Japanese (Japan)
    public static let jaJP = Locale(identifier: "ja-JP")
    /// Korean
    public static let ko = Locale(identifier: "ko")
    /// Korean (South Korea)
    public static let koKR = Locale(identifier: "ko-KR")
    /// Portuguese
    public static let pt = Locale(identifier: "pt")
    /// Portuguese (Brazil)
    public static let ptBR = Locale(identifier: "pt-BR")
    /// Russian
    public static let ru = Locale(identifier: "ru")
    /// Russian (Russia)
    public static let ruRU = Locale(identifier: "ru-RU")
    /// Spanish
    public static let es = Locale(identifier: "es")
    /// Spanish (Spain)
    public static let esES = Locale(identifier: "es-ES")
    /// Turkish
    public static let tr = Locale(identifier: "tr")
    /// Turkish (Turkey)
    public static let trTR = Locale(identifier: "tr-TR")
}

/// A configuration to allow customizing localization.
public struct LocalizationConfiguration {
    let languageCode: String
    let localizableFilename: String
    let layoutDirection: LayoutDirection

    /// Creates an instance of `LocalizationConfiguration` with related parameters. Allow
    /// overriding strings of localization keys with Localizable.strings file or other localizable filename.
    /// - Parameter locale: Locale struct representing the language identifier (ie. en, fr, fr-FR,
    /// zh-Hant, zh-Hans, ...), with or without region. If Locale identifier is not valid, will default to `en`.
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
    /// - Returns: Get supported Locales the AzureCommunicationUICalling
    ///  has predefined translations.
    public static var supportedLocales: [Locale] {
        return Bundle(for: CallComposite.self).localizations.sorted()
            .map { Locale(identifier: $0) }
    }
}
