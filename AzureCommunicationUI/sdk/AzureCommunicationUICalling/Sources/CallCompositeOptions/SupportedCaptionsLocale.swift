//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
/// SupportedCaptionsLocale representing the supported locales.
public struct SupportedCaptionsLocale {
    // Adding predefined locales as per the TypeScript interface CaptionLanguageStrings
    public static let ar = Locale(identifier: "ar")
    public static let zhHans = Locale(identifier: "zh-Hans")
    public static let zhHant = Locale(identifier: "zh-Hant")
    public static let nl = Locale(identifier: "nl")
    public static let en = Locale(identifier: "en")
    public static let fi = Locale(identifier: "fi")
    public static let fr = Locale(identifier: "fr")
    public static let frCA = Locale(identifier: "fr-CA") // French (Canada)
    public static let de = Locale(identifier: "de")
    public static let he = Locale(identifier: "he")
    public static let it = Locale(identifier: "it")
    public static let ja = Locale(identifier: "ja")
    public static let ko = Locale(identifier: "ko")
    public static let nb = Locale(identifier: "nb")
    public static let pl = Locale(identifier: "pl")
    public static let pt = Locale(identifier: "pt")
    public static let ptPT = Locale(identifier: "pt-PT") // Portuguese (Portugal)
    public static let ru = Locale(identifier: "ru")
    public static let es = Locale(identifier: "es")
    public static let sv = Locale(identifier: "sv")
    public static let tr = Locale(identifier: "tr")
    public static let vi = Locale(identifier: "vi") // Vietnamese
    public static let th = Locale(identifier: "th") // Thai
    public static let da = Locale(identifier: "da") // Danish
    public static let cs = Locale(identifier: "cs") // Czech
    public static let cy = Locale(identifier: "cy") // Welsh
    public static let uk = Locale(identifier: "uk") // Ukrainian
    public static let el = Locale(identifier: "el") // Greek
    public static let hu = Locale(identifier: "hu") // Hungarian
    public static let ro = Locale(identifier: "ro") // Romanian
    public static let sk = Locale(identifier: "sk") // Slovak

    /// Get supported locales the AzureCommunicationUICalling has predefined translations.
    /// - Returns: Array of supported Locales the AzureCommunicationUICalling has predefined translations.
    public static var values: [Locale] {
        return Bundle(for: CallComposite.self).localizations.sorted()
            .map { Locale(identifier: $0) }
    }
}
