//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI

public struct LocalizationConfiguration {
    let customStrings: [String: String]
    let locale: String
    let localizableFilename: String
    let isRightToLeft: Bool

    /// Create an instance of LocalizationConfiguration to customize localization.
    /// - Parameter locale: Name of the language locale.
    /// - Parameter localizableFilename:Name of the localizable strings file to override
    ///  predefined Call Composite's localization string or to provide localization for an unsupported
    ///  language.  The key of the string should be matched with the one in AzureCommunicationUI.
    ///  Default value is "" (empty strings).
    /// - Parameter isRightToLeft: Boolean for mirroring layout for right-to-left.
    ///  Default value is `false`.
    public init(locale: String,
                localizableFilename: String = "",
                isRightToLeft: Bool = false) {
        self.customStrings = [:]
        self.locale = locale
        self.localizableFilename = localizableFilename
        self.isRightToLeft = isRightToLeft
    }

    /// Create an instance of LocalizationConfiguration to customize localization.
    /// - Parameter customStrings: A dictionary of key-value pairs to override override
    ///  predefined Call Composite's localization string. The key of the string should be matched
    ///  with the one in AzureCommunicationUI.
    /// - Parameter locale: Name of the language locale.
    /// - Parameter isRightToLeft: Boolean for mirroring layout for right-to-left.
    ///  Default value is `false`.
    public init(customStrings: [String: String],
                locale: String,
                isRightToLeft: Bool = false) {
        self.customStrings = customStrings
        self.locale = locale
        self.localizableFilename = ""
        self.isRightToLeft = isRightToLeft
    }

    /// Get supported languages the Call Composite is localized to.
    /// - Returns: A list of language names for the locales that has predefined localized strings for
    public static func getSupportedLanguages() -> [String] {
        return LocalizationProvider.supportedLocales
    }

    /// Get the locale string dictionary for key-value pairs of a locale that is supported by Call Composite.
    /// - Parameter locale: The name of the locale that is supported by Call Composite.
    /// - Returns: A dictionary of key-value pair for localization keys with the string value of a given locale.
    ///  Returns empty dictionary if the locale is not supported.
    public static func getLocaleStringDict(locale: String) -> [String: String] {
        return LocalizationProvider.getLocaleDictionary(locale: locale)
    }
}
