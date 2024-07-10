//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == CaptionsState, Actions == CaptionsAction {
    static var captionsReducer: Self = Reducer { currentState, action in
        var newState = currentState
        switch action {
        case .startRequested(let language):
            newState.isEnabled = true
        case .started:
            newState.isStarted = true
        case .stopped:
            newState.isStarted = false
            newState.isEnabled = false
        case .spokenLanguageChanged(let language):
            newState.activeSpokenLanguage = formatLocaleIdentifier(language)
        case .captionLanguageChanged(let language):
            newState.activeCaptionLanguage = formatLocaleIdentifier(language)
        case .isTranslationSupportedChanged(let isSupported):
            newState.isTranslationSupported = isSupported
        case .error(let errors):
            newState.errors = errors
            if newState.errors == .captionsFailedToStart {
                newState.isEnabled = false
            }
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
