//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

protocol LocalizationProvider {
    var isRightToLeft: Bool { get }
    func apply(localeConfig: LocalizationConfiguration)
    func getSupportedLanguages() -> [String]
    func getLocalizedString(_ key: LocalizationKey) -> String
    func getLocalizedString(_ key: LocalizationKey, _ args: CVarArg...) -> String
}

class AppLocalizationProvider: LocalizationProvider {
    private let logger: Logger
    private var languageCode: String = "en"
    private var localizableFilename: String = ""
    private var customTranslations: [String: String] = [:]
    private(set) var isRightToLeft: Bool = false

    var supportedLocales: [String] = Bundle(for: CallComposite.self).localizations

    init(logger: Logger) {
        self.logger = logger
    }

    func apply(localeConfig: LocalizationConfiguration) {
        if !supportedLocales.contains(localeConfig.languageCode) {
            let warningMessage = "Language not supported by default for " +
            "`\(localeConfig.languageCode)`, if string for AzureCommunicationUI " +
            "localization keys not provided in custom Localizable.strings " +
            "or customString, strings will default to `en`"
            logger.warning(warningMessage)
        }

        languageCode = localeConfig.languageCode
        localizableFilename = localeConfig.localizableFilename
        customTranslations = localeConfig.customTranslations
        isRightToLeft = localeConfig.isRightToLeft
    }

    func getSupportedLanguages() -> [String] {
        return supportedLocales
    }

    func getLocalizedString(_ key: LocalizationKey) -> String {
        if let customTranslation = customTranslations[key.rawValue] {
            return customTranslation
        }

        if let path = Bundle.main
            .path(forResource: languageCode, ofType: "lproj"),
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

    func getLocalizedString(_ key: LocalizationKey, _ args: CVarArg...) -> String {
        let stringFormat = getLocalizedString(key)
        return String(format: stringFormat, arguments: args)
    }

    private func getPredefinedLocalizedString(_ key: String) -> String {
        if let path = Bundle(for: CallComposite.self)
            .path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let predefinedTranslation = NSLocalizedString(key,
                                                          bundle: bundle,
                                                          value: "localize_key_not_found",
                                                          comment: key)
            if predefinedTranslation != "localize_key_not_found" {
                return predefinedTranslation
            }
        }
        return NSLocalizedString(key,
                                 bundle: Bundle(for: CallComposite.self),
                                 value: key,
                                 comment: key)
    }
}
