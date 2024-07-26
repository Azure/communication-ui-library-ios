//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == CaptionsState, Actions == CaptionsAction {
    static var captionsReducer: Self = Reducer { currentState, action in
        var newState = currentState
        switch action {
        case .turnOnCaptions(let language):
            newState.isCaptionsOn = true
        case .started:
            newState.isStarted = true
        case .turnOffCaptions:
            newState.isCaptionsOn = false
        case .stopped:
            newState.isStarted = false
        case .spokenLanguageChanged(let language):
            newState.spokenLanguage = formatLocaleIdentifier(language)
        case .captionLanguageChanged(let language):
            newState.captionLanguage = formatLocaleIdentifier(language)
        case .isTranslationSupportedChanged(let isSupported):
            newState.isTranslationSupported = isSupported
        case .error(let errors):
            newState.errors = errors
        case .supportedSpokenLanguagesChanged(let languages):
            newState.supportedSpokenLanguages = languages.map(formatLocaleIdentifier)
        case .supportedCaptionLanguagesChanged(let languages):
            newState.supportedCaptionLanguages = languages
        case .typeChanged(let type):
            newState.activeType = type
        default:
            return newState
        }
        return newState
    }

    static func formatLocaleIdentifier(_ identifier: String) -> String {
        let components = identifier.split(separator: "-").map(String.init)
        guard components.count > 1 else {
            return identifier
        }
        return components.enumerated().map { index, component in
            index == 1 ? component.uppercased() : component
        }.joined(separator: "-")
    }
}
