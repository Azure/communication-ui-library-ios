//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation

struct CaptionsState: Equatable {
    var isCaptionsOn: Bool
    var isStarted: Bool
    var supportedSpokenLanguages: [String]?
    var spokenLanguage: String?
    var supportedCaptionLanguages: [String]?
    var captionLanguage: String?
    var isTranslationSupported: Bool?
    var activeType: CallCompositeCaptionsType = .none
    var errors: CallCompositeCaptionsErrors = .none

    init(isEnabled: Bool = false,
         isStarted: Bool = false,
         supportedSpokenLanguages: [String] = [],
         activeSpokenLanguage: String = "en-US",
         supportedCaptionLanguages: [String] = [],
         activeCaptionLanguage: String = "",
         isTranslationSupported: Bool = false,
         activeType: CallCompositeCaptionsType = .none,
         errors: CallCompositeCaptionsErrors = .none) {
           self.isCaptionsOn = isEnabled
           self.isStarted = isStarted
           self.supportedSpokenLanguages = supportedSpokenLanguages
           self.spokenLanguage = activeSpokenLanguage
           self.supportedCaptionLanguages = supportedCaptionLanguages
           self.captionLanguage = activeCaptionLanguage
           self.isTranslationSupported = isTranslationSupported
           self.activeType = activeType
           self.errors = errors
       }
}
