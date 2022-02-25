//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct LocalizationProvider {
    let logger: Logger?
    static var locale: String = "en"
    static var supportedLocales: [String] = Bundle(for: CallComposite.self).localizations

    func applyLocalizationConfiguration(_ localeConfig: LocalizationConfiguration) {
        if !LocalizationProvider.supportedLocales.contains(localeConfig.locale) {
            let warningMessage = "Locale not supported by default for " +
            "`\(localeConfig.locale)`, if string for AzureCommunicationUI " +
            "localization keys not provided in custom Localizable.strings " +
            "or customString, strings will default to `en`"
            logger?.warning(warningMessage)
        }

        LocalizationProvider.locale = localeConfig.locale
    }

    static func getSupportedLanguages() -> [String] {
        return supportedLocales
    }

    static func getLocaleDictionary(locale: String) -> [String: String] {
        var predefinedLocaleStrings: [String: String] = [:]
        guard let path = Bundle(for: CallComposite.self)
                .url(forResource: "Localizable",
                     withExtension: "strings",
                     subdirectory: nil,
                     localization: locale),
              let localizableStrings = NSDictionary(contentsOf: path) else {
            return predefinedLocaleStrings
        }

        for key in localizableStrings.allKeys {
            if let stringKey = key as? String,
               let stringValue = localizableStrings.value(forKey: stringKey) {
                predefinedLocaleStrings[stringKey] = stringValue as? String
            }
        }

        return predefinedLocaleStrings
    }
}
