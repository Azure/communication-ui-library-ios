//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

protocol LocalizationProviderProtocol {
    var isRightToLeft: Bool { get }
    func getLocalizedString(_ key: LocalizationKey) -> String
}

class LocalizationProvider: LocalizationProviderProtocol {
    private let logger: Logger
    private var languageIdentifier: String = "en"
    private var languageCode: String = "en"
    private var localizableFilename: String = ""
    private(set) var isRightToLeft: Bool = false

    init(logger: Logger) {
        self.logger = logger
        self.detectSystemLanguage()
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
}

// MARK: Helper functions
extension LocalizationProvider {
    private func detectSystemLanguage() {
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

    private func getPredefinedLocalizedString(_ key: String) -> String {
        if let predefinedTranslation = findPredefinedLocalizedString(languageIdentifier, key) {
            return predefinedTranslation
        }
        if let predefinedTranslation = findPredefinedLocalizedString(languageCode, key) {
            return predefinedTranslation
        }
        return NSLocalizedString(key,
                                 bundle: Bundle(for: ChatComposite.self),
                                 value: key,
                                 comment: key)
    }

    private func findPredefinedLocalizedString(_ languageCode: String,
                                               _ key: String) -> String? {
        guard let path = Bundle(for: ChatComposite.self)
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
