//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI

/// SupportedLocale representing the supported locales.
public struct SupportedLocale {
    /// Arabic
    public static let ar = Locale(identifier: "ar")
    /// Arabic (Saudi Arabia)
    public static let arSA = Locale(identifier: "ar-SA")
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
    /// Finnish
    public static let fi = Locale(identifier: "fi")
    /// Finnish (Finland)
    public static let fiFI = Locale(identifier: "fi-FI")
    /// French
    public static let fr = Locale(identifier: "fr")
    /// French (France)
    public static let frFR = Locale(identifier: "fr-FR")
    /// German
    public static let de = Locale(identifier: "de")
    /// German (Germany)
    public static let deDE = Locale(identifier: "de-DE")
    /// Hebrew
    public static let he = Locale(identifier: "he")
    /// Hebrew (Israel)
    public static let heIL = Locale(identifier: "he-IL")
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
    /// Norwegian Bokmål
    public static let nb = Locale(identifier: "nb")
    /// Norwegian Bokmål (Norway)
    public static let nbNO = Locale(identifier: "nb-NO")
    /// Polish
    public static let pl = Locale(identifier: "pl")
    /// Polish (Poland)
    public static let plPL = Locale(identifier: "pl-PL")
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
    /// Swedish
    public static let sv = Locale(identifier: "sv")
    /// Swedish (Sweden)
    public static let svSE = Locale(identifier: "sv-SE")
    /// Turkish
    public static let tr = Locale(identifier: "tr")
    /// Turkish (Turkey)
    public static let trTR = Locale(identifier: "tr-TR")

    /// Get supported locales the AzureCommunicationUICalling has predefined translations.
    /// - Returns: Get supported Locales the AzureCommunicationUICalling
    ///  has predefined translations.
    public static var values: [Locale] {
        return Bundle(for: CallComposite.self).localizations.sorted()
            .map { Locale(identifier: $0) }
    }
}
