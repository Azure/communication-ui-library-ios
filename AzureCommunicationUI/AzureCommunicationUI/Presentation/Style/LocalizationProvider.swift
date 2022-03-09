//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

protocol LocalizationProvider {
    func apply(localeConfig: LocalizationConfiguration)
    func getSupportedLanguages() -> [String]
    func getLocalizedString(_ key: StringKey) -> String
    func getLocalizedString(_ key: StringKey, _ args: CVarArg...) -> String
}

class AppLocalizationProvider: LocalizationProvider {
    private let logger: Logger
    private var locale: String = "en"
    private var localizableFilename: String = ""
    private var customTranslations: [String: String] = [:]
    private var isRightToLeft: Bool = false

    var supportedLocales: [String] = Bundle(for: CallComposite.self).localizations

    init(logger: Logger) {
        self.logger = logger
    }

    func apply(localeConfig: LocalizationConfiguration) {
        if !supportedLocales.contains(localeConfig.locale) {
            let warningMessage = "Locale not supported by default for " +
            "`\(localeConfig.locale)`, if string for AzureCommunicationUI " +
            "localization keys not provided in custom Localizable.strings " +
            "or customString, strings will default to `en`"
            logger.warning(warningMessage)
        }

        locale = localeConfig.locale
        localizableFilename = localeConfig.localizableFilename
        customTranslations = localeConfig.customTranslations
    }

    func getSupportedLanguages() -> [String] {
        return supportedLocales
    }

    func getLocalizedString(_ key: StringKey) -> String {
        if let customTranslation = customTranslations[key.rawValue] {
            return customTranslation
        }

        if let path = Bundle.main
            .path(forResource: locale, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let customLocalizableString = NSLocalizedString(key.rawValue,
                                                            tableName: localizableFilename,
                                                            bundle: bundle,
                                                            value: "localize_key_not_found",
                                                            comment: key.rawValue)
            if customLocalizableString != "localize_key_not_found" {
                return customLocalizableString
            }
        }
        return getPredefinedLocalizedString(key.rawValue)
    }

    func getLocalizedString(_ key: StringKey, _ args: CVarArg...) -> String {
        let stringFormat = getLocalizedString(key)
        return String(format: stringFormat, arguments: args)
    }

    private func getPredefinedLocalizedString(_ key: String) -> String {
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
