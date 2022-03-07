//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI

public struct LocalizationConfiguration {
    let locale: String
    let localizableFilename: String
    let customTranslations: [String: String]
    let isRightToLeft: Bool

    /// Create an instance of LocalizationConfiguration to customize localization.
    /// - Parameter locale: String representing the locale code (ie. en, fr,  zh-Hant, zh-Hans, ...).
    /// - Parameter localizableFilename: Name of the localizable strings file to override
    ///  predefined Call Composite's localization string or to provide localization for an unsupported
    ///  language.  The key of the string should be matched with the one in AzureCommunicationUI.
    ///  Default value is "" (empty strings).
    /// - Parameter isRightToLeft: Boolean for mirroring layout for right-to-left.
    ///  Default value is `false`.
    public init(locale: String,
                localizableFilename: String = "",
                isRightToLeft: Bool = false) {
        self.locale = locale
        self.localizableFilename = localizableFilename
        self.customTranslations = [:]
        self.isRightToLeft = isRightToLeft
    }

    /// Create an instance of LocalizationConfiguration to customize localization.
    /// - Parameter locale: String representing the locale code (ie. en, fr,  zh-Hant, zh-Hans, ...).
    /// - Parameter customTranslations: A dictionary of key-value pairs to override override
    ///  predefined Call Composite's localization string. The key of the string should be matched
    ///  with the one in AzureCommunicationUI.
    /// - Parameter isRightToLeft: Boolean for mirroring layout for right-to-left.
    ///  Default value is `false`.
    public init(locale: String,
                customTranslations: [String: String],
                isRightToLeft: Bool = false) {
        self.locale = locale
        self.localizableFilename = ""
        self.customTranslations = customTranslations
        self.isRightToLeft = isRightToLeft
    }

    /// Get supported languages the Call Composite is localized to.
    /// - Returns: A list of language names for the locale codes that has predefined localized strings for
    public static func getSupportedLanguages() -> [String] {
        return LocalizationProvider.supportedLocales
    }
}
