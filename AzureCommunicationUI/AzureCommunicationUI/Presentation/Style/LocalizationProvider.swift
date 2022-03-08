//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct LocalizationProvider {
    let logger: Logger?
    static var locale: String = "en"
    static var localizableFilename: String = ""
    static var customTranslations: [String: String] = [:]
    static var isRightToLeft: Bool = false

    static var supportedLocales: [String] = Bundle(for: CallComposite.self).localizations

    static var layoutDirection: LayoutDirection {
        isRightToLeft ? .rightToLeft : .leftToRight
    }
    static var layoutDirectionUIKit: UISemanticContentAttribute {
        isRightToLeft ? .forceRightToLeft : .forceLeftToRight
    }

    func applyLocalizationConfiguration(_ localeConfig: LocalizationConfiguration) {
        if !LocalizationProvider.supportedLocales.contains(localeConfig.locale) {
            let warningMessage = "Locale not supported by default for " +
            "`\(localeConfig.locale)`, if string for AzureCommunicationUI " +
            "localization keys not provided in custom Localizable.strings " +
            "or customString, strings will default to `en`"
            logger?.warning(warningMessage)
        }

        LocalizationProvider.locale = localeConfig.locale
        LocalizationProvider.localizableFilename = localeConfig.localizableFilename
        LocalizationProvider.customTranslations = localeConfig.customTranslations
        LocalizationProvider.isRightToLeft = localeConfig.isRightToLeft
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

    static func getLocalizedString(_ key: String) -> String {
        if let customTranslation = customTranslations[key] {
            return customTranslation
        }

        if let path = Bundle.main
            .path(forResource: locale, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let customLocalizableString = NSLocalizedString(key,
                                                            tableName: localizableFilename,
                                                            bundle: bundle,
                                                            value: "localize_key_not_found",
                                                            comment: key)
            if customLocalizableString != "localize_key_not_found" {
                return customLocalizableString
            }
        }
        return getPredefinedLocalizedString(key)
    }

    static func getLocalizedString(_ key: String, _ args: CVarArg...) -> String {
        var stringFormat = getLocalizedString(key)

        // check if more placeholder than arguments
        if stringFormat.components(separatedBy: "%").count - 1 > args.count {
            stringFormat = getPredefinedLocalizedString(key)
        }
        return String(format: stringFormat, arguments: args)
    }

    private static func getPredefinedLocalizedString(_ key: String) -> String {
        if let path = Bundle(for: CallComposite.self)
            .path(forResource: locale, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(key, bundle: bundle, comment: key)
        }
        return NSLocalizedString(key,
                                 bundle: Bundle(for: CallComposite.self),
                                 value: key,
                                 comment: key)
    }
}
