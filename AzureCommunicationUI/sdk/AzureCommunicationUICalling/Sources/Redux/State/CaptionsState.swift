//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation

struct CaptionsState: Equatable {
    var isEnabled: Bool?
    var isStarted: Bool
    var supportedSpokenLanguages: [String]?
    var activeSpokenLanguage: String?
    var supportedCaptionLanguages: [String]?
    var activeCaptionLanguage: String?
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
           self.isEnabled = isEnabled
           self.isStarted = isStarted
           self.supportedSpokenLanguages = supportedSpokenLanguages
           self.activeSpokenLanguage = activeSpokenLanguage
           self.supportedCaptionLanguages = supportedCaptionLanguages
           self.activeCaptionLanguage = activeCaptionLanguage
           self.isTranslationSupported = isTranslationSupported
           self.activeType = activeType
           self.errors = errors
       }
}