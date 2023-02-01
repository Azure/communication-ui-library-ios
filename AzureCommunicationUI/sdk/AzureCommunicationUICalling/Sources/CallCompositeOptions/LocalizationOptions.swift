//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI

/// Options to allow customizing localization.
public struct LocalizationOptions {
    let languageCode: String
    let localizableFilename: String
    let layoutDirection: LayoutDirection

    /// Creates an instance of `LocalizationOptions` with related parameters. Allow
    /// overriding strings of localization keys with Localizable.strings file or other localizable filename.
    /// - Parameter locale: Locale struct representing the language identifier (ie. en, fr, fr-FR,
    /// zh-Hant, zh-Hans, ...), with or without region. If Locale identifier is not valid, will default to `en`.
    /// - Parameter localizableFilename: Filename of the `.strings` file to override predefined
    ///  Call Composite's localization key or to provide translation for an custom language.
    ///  The keys of the string should match with the keys from AzureCommunicationUI
    ///  localization keys. Default value is `"Localizable"`.
    /// - Parameter layoutDirection: LayoutDirection for mirroring layout for right-to-left.
    ///  Default value is `false`.
    public init(locale: Locale,
                localizableFilename: String = "Localizable",
                layoutDirection: LayoutDirection = .leftToRight) {
        self.languageCode = locale.collatorIdentifier ?? "en"
        self.localizableFilename = localizableFilename
        self.layoutDirection = layoutDirection
    }
}
