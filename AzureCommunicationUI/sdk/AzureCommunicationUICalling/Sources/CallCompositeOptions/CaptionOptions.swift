//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation

/// Configuration options for captions in a UI component.
public struct CaptionsOptions {
    var captionsOn: Bool
    var spokenLanguage: String

    public init(captionsOn: Bool = false, spokenLanguage: String = "") {
        self.spokenLanguage = spokenLanguage
        self.captionsOn = captionsOn
    }
}
