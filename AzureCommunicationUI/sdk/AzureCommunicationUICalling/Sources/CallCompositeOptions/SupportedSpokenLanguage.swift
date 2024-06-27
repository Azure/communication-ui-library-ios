//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// SupportedCaptionsLanguage representing the supported languages.
public struct SupportedSpokenLanguage {
    public static let arAE = "ar-AE"
    public static let arSA = "ar-SA"
    public static let daDK = "da-DK"
    public static let deDE = "de-DE"
    public static let enAU = "en-AU"
    public static let enCA = "en-CA"
    public static let enGB = "en-GB"
    public static let enIN = "en-IN"
    public static let enNZ = "en-NZ"
    public static let enUS = "en-US"
    public static let esES = "es-ES"
    public static let esMX = "es-MX"
    public static let fiFI = "fi-FI"
    public static let frCA = "fr-CA"
    public static let frFR = "fr-FR"
    public static let hiIN = "hi-IN"
    public static let itIT = "it-IT"
    public static let jaJP = "ja-JP"
    public static let koKR = "ko-KR"
    public static let nbNO = "nb-NO"
    public static let nlBE = "nl-BE"
    public static let nlNL = "nl-NL"
    public static let plPL = "pl-PL"
    public static let ptBR = "pt-BR"
    public static let ruRU = "ru-RU"
    public static let svSE = "sv-SE"
    public static let zhCN = "zh-CN"
    public static let zhHK = "zh-HK"

    public static var values: [String] {
        return [
            arAE, arSA, daDK, deDE, enAU, enCA, enGB, enIN, enNZ, enUS,
            esES, esMX, fiFI, frCA, frFR, hiIN, itIT, jaJP, koKR, nbNO,
            nlBE, nlNL, plPL, ptBR, ruRU, svSE, zhCN, zhHK
        ]
    }
}
