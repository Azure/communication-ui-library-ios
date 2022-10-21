//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

// @_spi(common) import AzureCommunicationUICommon
import Foundation
import SwiftUI

protocol LocalizationProviderProtocol {
    var isRightToLeft: Bool { get }
    func apply(localeConfig: LocalizationOptions)
    func getLocalizedString(_ key: LocalizationKey) -> String
    func getLocalizedString(_ key: LocalizationKey, _ args: CVarArg...) -> String
}

class LocalizationProvider: LocalizationProviderProtocol {
    private let logger: Logger
    private var languageIdentifier: String = "en"
    private var languageCode: String = "en"
    private var localizableFilename: String = ""
    private(set) var isRightToLeft: Bool = false

    var supportedLocales: [String] = Bundle(for: CallComposite.self).localizations

    init(logger: Logger) {
        self.logger = logger
        self.detectSystemLanguage()
    }

    func detectSystemLanguage() {
        guard let preferredLanguageId = Locale.preferredLanguages.first else {
            return
        }
        let preferredLanguageCode = removeRegionCode(preferredLanguageId)

        if self.isLanguageSupportedByApp(preferredLanguageId) {
            self.languageIdentifier = preferredLanguageId
            self.languageCode = preferredLanguageCode
        } else if self.isLanguageSupportedByApp(preferredLanguageCode) {
            self.languageIdentifier = preferredLanguageCode
            self.languageCode = preferredLanguageCode
        } else if let systemLanguageCode = Locale.current.languageCode,
                  self.isLanguageSupportedByApp(systemLanguageCode) {
            self.languageIdentifier = systemLanguageCode
            self.languageCode = systemLanguageCode
        }
    }

    func apply(localeConfig: LocalizationOptions) {
        if !supportedLocales.contains(localeConfig.languageCode) {
            let warningMessage = "Locale not supported by default for " +
            "`\(localeConfig.languageCode)`, if string for AzureCommunicationUI " +
            "localization keys not provided in custom Localizable.strings " +
            "or customString, strings will default to `en`"
            logger.warning(warningMessage)
        }

        languageIdentifier = localeConfig.languageCode
        languageCode = removeRegionCode(localeConfig.languageCode)
        localizableFilename = localeConfig.localizableFilename
        isRightToLeft = localeConfig.layoutDirection == .rightToLeft
    }

    func getLocalizedString(_ key: LocalizationKey) -> String {
        if let path = Bundle.main
            .path(forResource: languageIdentifier, ofType: "lproj"),
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
        if let predefinedTranslation = findPredefinedLocalizedString(languageIdentifier, key) {
            return predefinedTranslation
        }
        if let predefinedTranslation = findPredefinedLocalizedString(languageCode, key) {
            return predefinedTranslation
        }
        return NSLocalizedString(key,
                                 bundle: Bundle(for: CallComposite.self),
                                 value: key,
                                 comment: key)
    }

    private func findPredefinedLocalizedString(_ languageCode: String,
                                               _ key: String) -> String? {
        guard let path = Bundle(for: CallComposite.self)
            .path(forResource: languageCode, ofType: "lproj") else {
            return nil
        }
        guard let bundle = Bundle(path: path) else {
            return nil
        }
        let predefinedTranslation = NSLocalizedString(key,
                                                      bundle: bundle,
                                                      value: "localize_key_not_found",
                                                      comment: key)
        if predefinedTranslation != "localize_key_not_found" {
            return predefinedTranslation
        }
        return nil
    }

    private func removeRegionCode(_ languageId: String) -> String {
        let languageComponents = languageId
            .replacingOccurrences(of: "_", with: "-")
            .components(separatedBy: "-")
        return languageComponents.count == 1
        ? languageId
        : languageComponents[..<(languageComponents.count - 1)]
            .joined(separator: "-")
    }

    private func isLanguageSupportedByApp(_ languageId: String) -> Bool {
        return Bundle.main.localizations.contains(languageId)
    }
}
