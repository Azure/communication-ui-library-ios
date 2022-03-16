//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI

public struct LocalizationConfiguration {
    let languageCode: String
    let localizableFilename: String
    let customTranslations: [String: String]
    let isRightToLeft: Bool

    /// Creates an instance of `LocalizationConfiguration` with related parameters. Allow
    /// overriding strings of localization keys with Localizable.strings file or other localizable filename.
    /// - Parameter languageCode: String representing the locale code (ie. en, fr, zh-Hant, zh-Hans, ...).
    /// - Parameter localizableFilename: Filename of the `.strings` file to override predefined
    ///  Call Composite's localization key or to provide translation for an custom language.
    ///  The keys of the string should match with the keys from AzureCommunicationUI
    ///  localization keys. Default value is `""`.
    /// - Parameter isRightToLeft: Boolean for mirroring layout for right-to-left.
    ///  Default value is `false`.
    public init(languageCode: String,
                localizableFilename: String = "",
                isRightToLeft: Bool = false) {
        self.languageCode = languageCode
        self.localizableFilename = localizableFilename
        self.customTranslations = [:]
        self.isRightToLeft = isRightToLeft
    }

    /// Creates an instance of `LocalizationConfiguration` with related parameters. Allow
    /// overriding strings of localization keys with dictionary.
    /// - Parameter languageCode: String representing the locale code (ie. en, fr, zh-Hant, zh-Hans, ...).
    /// - Parameter customTranslations: A dictionary of key-value pairs to override
    ///  predefined AzureCommunicationUICalling's localization string. The keys of the string
    ///  should match with the keys from AzureCommunicationUI localization keys.
    /// - Parameter isRightToLeft: Boolean for mirroring layout for right-to-left.
    ///  Default value is `false`.
    public init(languageCode: String,
                customTranslations: [String: String],
                isRightToLeft: Bool = false) {
        self.languageCode = languageCode
        self.localizableFilename = ""
        self.customTranslations = customTranslations
        self.isRightToLeft = isRightToLeft
    }

    /// Get supported languages the AzureCommunicationUICalling has predefined translations.
    /// - Returns: Get supported languages the AzureCommunicationUICalling
    ///  has predefined translations.
    public static func getSupportedLanguages() -> [String] {
        return Bundle(for: CallComposite.self).localizations
    }
}
