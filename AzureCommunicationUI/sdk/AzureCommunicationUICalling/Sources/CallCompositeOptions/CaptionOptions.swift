//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation

/// Configuration options for captions in a UI component.
public struct CaptionsOptions {
    var startCaptions: Bool
    var spokenLanguage: String

    public init(startCaptions: Bool = false, spokenLanguage: String = "en-US") {
        let currentLocaleIdentifier = Locale.current.identifier

        self.spokenLanguage = spokenLanguage
        self.startCaptions = startCaptions
    }
}
