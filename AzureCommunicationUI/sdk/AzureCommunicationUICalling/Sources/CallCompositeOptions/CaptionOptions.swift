//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation

/// Configuration options for captions in a UI component.
public struct CaptionsOptions {
    let enableCaptions: Bool
    let spokenLanguage: String
    public init(spokenLanguage: Locale,
                enableCaptions: Bool = false) {
        let currentLocale = Locale.current
        let supportedLocales = SupportedCaptionsLocale.values

        // Check if user-provided spokenLanguage is supported
        if supportedLocales.contains(where: { $0.identifier == spokenLanguage.identifier }) {
            self.spokenLanguage = spokenLanguage.identifier
        } else if supportedLocales.contains(where: { $0.identifier == currentLocale.identifier }) {
            // If the spokenLanguage is not supported but currentLocale is, use currentLocale
            self.spokenLanguage = currentLocale.identifier
        } else {
            self.spokenLanguage = "en"  // Default to English
        }

        self.enableCaptions = enableCaptions
    }
}

public enum EnableCaptionsOptions {
    case enableCaptions
    case disableCaptions
    var rawValue: String {
        switch self {
        case .enableCaptions:
            return "enableCaptions"
        case .disableCaptions:
            return "disableCaptions"
        }
    }
}
