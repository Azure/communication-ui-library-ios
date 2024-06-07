//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == CaptionsState, Actions == CaptionsAction {
    static var captionsReducer: Self = Reducer { currentState, action in
        var newState = currentState
        switch action {
        case .started:
            newState.isStarted = true
        case .stopped:
            newState.isStarted = false
        case .spokenLanguageChanged(let language):
            newState.activeSpokenLanguage = language
        case .captionLanguageChanged(let language):
            newState.activeCaptionLanguage = language
        case .isTranslationSupportedChanged(let isSupported):
            newState.isTranslationSupported = isSupported
        case .error(let errors):
            newState.errors = errors
        case .supportedSpokenLanguagesChanged(let languages):
            newState.supportedSpokenLanguages = languages
        case .supportedCaptionLanguagesChanged(let languages):
            newState.supportedCaptionLanguages = languages
        case .typeChanged(let type):
            newState.activeType = type
        case .showCaptionsOptions:
            newState.showCaptionsOptions = true
        case .closeCaptionsOptions:
            newState.showCaptionsOptions = false
        case .showSupportedSpokenLanguagesOptions:
            newState.showSupportedSpokenLanguages = true
        case .showSupportedCaptionLanguagesOptions:
            newState.showSupportedCaptionLanguages = true
        case .hideSupportedLanguagesOptions:
            newState.showSupportedSpokenLanguages = false
            newState.showSupportedCaptionLanguages = false
        default:
            return newState
        }
        return newState
    }
}
