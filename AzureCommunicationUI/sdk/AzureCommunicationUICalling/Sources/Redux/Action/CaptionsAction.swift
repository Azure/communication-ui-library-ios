//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum CaptionsAction: Equatable {
    case startRequested(language: String)
    case started
    case stopRequested
    case stopped
    case setSpokenLanguageRequested(language: String)
    case spokenLanguageChanged(language: String)
    case setCaptionLanguageRequested(language: String)
    case captionLanguageChanged(language: String)
    case typeChanged(type: CallCompositeCaptionsType)
    case isTranslationSupportedChanged(isSupported: Bool)
    case error(errors: CallCompositeCaptionsErrors)
    case supportedSpokenLanguagesChanged(languages: [String])
    case supportedCaptionLanguagesChanged(languages: [String])
    case showCaptionsOptions
    case closeCaptionsOptions
    case showSupportedSpokenLanguagesOptions
    case showSupportedCaptionLanguagesOptions
    case hideSupportedLanguagesOptions
}
