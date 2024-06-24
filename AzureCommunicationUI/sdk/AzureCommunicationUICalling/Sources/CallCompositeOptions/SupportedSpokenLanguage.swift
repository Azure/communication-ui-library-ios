//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
/// SupportedCaptionsLocale representing the supported locales.
public struct SupportedSpokenLanguage {
    // Adding predefined locales as per the TypeScript interface CaptionLanguageStrings
    public static let arAE = Locale(identifier: "ar-AE")
    public static let arSA = Locale(identifier: "ar-SA")
    public static let daDK = Locale(identifier: "da-DK")
    public static let deDE = Locale(identifier: "de-DE")
    public static let enAU = Locale(identifier: "en-AU")
    public static let enCA = Locale(identifier: "en-CA")
    public static let enGB = Locale(identifier: "en-GB")
    public static let enIN = Locale(identifier: "en-IN")
    public static let enNZ = Locale(identifier: "en-NZ")
    public static let enUS = Locale(identifier: "en-US")
    public static let esES = Locale(identifier: "es-ES")
    public static let esMX = Locale(identifier: "es-MX")
    public static let fiFI = Locale(identifier: "fi-FI")
    public static let frCA = Locale(identifier: "fr-CA")
    public static let frFR = Locale(identifier: "fr-FR")
    public static let hiIN = Locale(identifier: "hi-IN")
    public static let itIT = Locale(identifier: "it-IT")
    public static let jaJP = Locale(identifier: "ja-JP")
    public static let koKR = Locale(identifier: "ko-KR")
    public static let nbNO = Locale(identifier: "nb-NO")
    public static let nlBE = Locale(identifier: "nl-BE")
    public static let nlNL = Locale(identifier: "nl-NL")
    public static let plPL = Locale(identifier: "pl-PL")
    public static let ptBR = Locale(identifier: "pt-BR")
    public static let ruRU = Locale(identifier: "ru-RU")
    public static let svSE = Locale(identifier: "sv-SE")
    public static let zhCN = Locale(identifier: "zh-CN")
    public static let zhHK = Locale(identifier: "zh-HK")

    public static var values: [Locale] {
        return [
            arAE, arSA, daDK, deDE, enAU, enCA, enGB, enIN, enNZ, enUS,
            esES, esMX, fiFI, frCA, frFR, hiIN, itIT, jaJP, koKR, nbNO,
            nlBE, nlNL, plPL, ptBR, ruRU, svSE, zhCN, zhHK
        ]
    }
}
