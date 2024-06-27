//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation

/// Configuration options for captions in a UI component.
public struct CaptionsOptions {
    var isOnByDefault: Bool
    var spokenLanguage: String

    public init(spokenLanguage: String = "en-US", enableCaptions: Bool = false) {
        let currentLocaleIdentifier = Locale.current.identifier

        // Check if user-provided spokenLanguage is supported
        if SupportedSpokenLanguage.values.contains(spokenLanguage) {
            self.spokenLanguage = spokenLanguage
        } else if SupportedSpokenLanguage.values.contains(currentLocaleIdentifier) {
            // If the spokenLanguage is not supported but currentLocale is, use currentLocale
            self.spokenLanguage = currentLocaleIdentifier
        } else {
            // Default to "en-US" if neither is supported
            self.spokenLanguage = "en-US"
        }

        self.isOnByDefault = enableCaptions
    }
}
