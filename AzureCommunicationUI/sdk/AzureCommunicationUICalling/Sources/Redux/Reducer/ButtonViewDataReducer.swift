//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

extension Reducer where State == ButtonViewDataState,
                        Actions == ButtonViewDataAction {
    static var buttonViewDataReducer: Self = Reducer { state, action in
        var setupScreenCameraButtonState = state.setupScreenCameraButtonState
        var setupScreenMicButtonState = state.setupScreenMicButtonState
        var setupScreenAudioDeviceButtonState = state.setupScreenAudioDeviceButtonState
        var callScreenCameraButtonState = state.callScreenCameraButtonState
        var callScreenMicButtonState = state.callScreenMicButtonState
        var callScreenAudioDeviceButtonState = state.callScreenAudioDeviceButtonState

        var liveCaptionsButton = state.liveCaptionsButton
        var liveCaptionsToggleButton = state.liveCaptionsToggleButton
        var spokenLanguageButton = state.spokenLanguageButton
        var captionsLanguageButton = state.captionsLanguageButton
        var shareDiagnosticsButton = state.shareDiagnosticsButton
        var reportIssueButton = state.reportIssueButton

        var callScreenCustomButtonsState = state.callScreenCustomButtonsState
        var callScreenHeaderCustomButtonsState = state.callScreenHeaderCustomButtonsState

        switch action {
        case .setupScreenAudioDeviceButtonIsEnabledUpdated(let enabled):
            guard let fromState = setupScreenAudioDeviceButtonState else {
                return state
            }
            setupScreenAudioDeviceButtonState = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .setupScreenAudioDeviceButtonIsVisibleUpdated(let visible):
            guard let fromState = setupScreenAudioDeviceButtonState else {
                return state
            }
            setupScreenAudioDeviceButtonState = DefaultButtonState(enabled: fromState.enabled, visible: visible)
        case .setupScreenMicButtonIsEnabledUpdated(let enabled):
            guard let fromState = setupScreenMicButtonState else {
                return state
            }
            setupScreenMicButtonState = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .setupScreenMicButtonIsVisibleUpdated(let visible):
            guard let fromState = setupScreenMicButtonState else {
                return state
            }
            setupScreenMicButtonState = DefaultButtonState(enabled: fromState.enabled, visible: visible)
        case .setupScreenCameraButtonIsEnabledUpdated(let enabled):
            guard let fromState = setupScreenCameraButtonState else {
                return state
            }
            setupScreenCameraButtonState = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .setupScreenCameraButtonIsVisibleUpdated(let visible):
            guard let fromState = setupScreenCameraButtonState else {
                return state
            }
            setupScreenCameraButtonState = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .callScreenAudioDeviceButtonIsEnabledUpdated(let enabled):
            guard let fromState = callScreenAudioDeviceButtonState else {
                return state
            }
            callScreenAudioDeviceButtonState = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .callScreenAudioDeviceButtonIsVisibleUpdated(let visible):
            guard let fromState = callScreenAudioDeviceButtonState else {
                return state
            }
            callScreenAudioDeviceButtonState = DefaultButtonState(enabled: fromState.enabled, visible: visible)
        case .callScreenMicButtonIsEnabledUpdated(let enabled):
            guard let fromState = callScreenMicButtonState else {
                return state
            }
            callScreenMicButtonState = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .callScreenMicButtonIsVisibleUpdated(let visible):
            guard let fromState = callScreenMicButtonState else {
                return state
            }
            callScreenMicButtonState = DefaultButtonState(enabled: fromState.enabled, visible: visible)
        case .callScreenCameraButtonIsEnabledUpdated(let enabled):
            guard let fromState = callScreenCameraButtonState else {
                return state
            }
            callScreenCameraButtonState = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .callScreenCameraButtonIsVisibleUpdated(let visible):
            guard let fromState = callScreenCameraButtonState else {
                return state
            }
            callScreenCameraButtonState = DefaultButtonState(enabled: fromState.enabled, visible: visible)
        case .callScreenReportIssueButtonIsEnabledUpdated(let enabled):
            guard let fromState = reportIssueButton else {
                return state
            }
            reportIssueButton = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .callScreenReportIssueButtonIsVisibleUpdated(let visible):
            guard let fromState = reportIssueButton else {
                return state
            }
            reportIssueButton = DefaultButtonState(enabled: fromState.enabled, visible: visible)
        case .callScreenShareDiagnosticsButtonIsEnabledUpdated(let enabled):
            guard let fromState = shareDiagnosticsButton else {
                return state
            }
            shareDiagnosticsButton = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .callScreenShareDiagnosticsButtonIsVisibleUpdated(let visible):
            guard let fromState = shareDiagnosticsButton else {
                return state
            }
            shareDiagnosticsButton = DefaultButtonState(enabled: fromState.enabled, visible: visible)
        case .callScreenLiveCaptionsButtonIsEnabledUpdated(let enabled):
            guard let fromState = liveCaptionsButton else {
                return state
            }
            liveCaptionsButton = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .callScreenLiveCaptionsButtonIsVisibleUpdated(let visible):
            guard let fromState = liveCaptionsButton else {
                return state
            }
            liveCaptionsButton = DefaultButtonState(enabled: fromState.enabled, visible: visible)
        case .callScreenLiveCaptionsToggleButtonIsEnabledUpdated(let enabled):
            guard let fromState = liveCaptionsToggleButton else {
                return state
            }
            liveCaptionsToggleButton = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .callScreenLiveCaptionsToggleButtonIsVisibleUpdated(let visible):
            guard let fromState = liveCaptionsToggleButton else {
                return state
            }
            liveCaptionsToggleButton = DefaultButtonState(enabled: fromState.enabled, visible: visible)
        case .callScreenSpokenLanguageButtonIsEnabledUpdated(let enabled):
            guard let fromState = spokenLanguageButton else {
                return state
            }
            spokenLanguageButton = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .callScreenSpokenLanguageButtonIsVisibleUpdated(let visible):
            guard let fromState = spokenLanguageButton else {
                return state
            }
            spokenLanguageButton = DefaultButtonState(enabled: fromState.enabled, visible: visible)
        case .callScreenCaptionsLanguageButtonIsEnabledUpdated(let enabled):
            guard let fromState = captionsLanguageButton else {
                return state
            }
            captionsLanguageButton = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .callScreenCaptionsLanguageButtonIsVisibleUpdated(let visible):
            guard let fromState = captionsLanguageButton else {
                return state
            }
            captionsLanguageButton = DefaultButtonState(enabled: fromState.enabled, visible: visible)
        case .callScreenCustomButtonIsEnabledUpdated(let id, let enabled):
            callScreenCustomButtonsState = callScreenCustomButtonsState.map { (customButton) in
                if customButton.id == id {
                    return CustomButtonState(id: id,
                                             enabled: enabled,
                                             visible: customButton.visible,
                                             image: customButton.image,
                                             title: customButton.title)
                } else {
                    return customButton
                }
            }
        case .callScreenCustomButtonIsVisibleUpdated(let id, let visible):
            callScreenCustomButtonsState = callScreenCustomButtonsState.map { (customButton) in
                if customButton.id == id {
                    return CustomButtonState(id: id,
                                             enabled: customButton.enabled,
                                             visible: visible,
                                             image: customButton.image,
                                             title: customButton.title)
                } else {
                    return customButton
                }
            }
        case .callScreenCustomButtonTitleUpdated(let id, let title):
            callScreenCustomButtonsState = callScreenCustomButtonsState.map { (customButton) in
                if customButton.id == id {
                    return CustomButtonState(id: id,
                                             enabled: customButton.enabled,
                                             visible: customButton.visible,
                                             image: customButton.image,
                                             title: title)
                } else {
                    return customButton
                }
            }
        case .callScreenCustomButtonIconUpdated(let id, let image):
            callScreenCustomButtonsState = callScreenCustomButtonsState.map { (customButton) in
                if customButton.id == id {
                    return CustomButtonState(id: id,
                                             enabled: customButton.enabled,
                                             visible: customButton.visible,
                                             image: image,
                                             title: customButton.title)
                } else {
                    return customButton
                }
            }
        case .callScreenHeaderCustomButtonIsEnabledUpdated(let id, let enabled):
            callScreenHeaderCustomButtonsState = callScreenHeaderCustomButtonsState.map { (customButton) in
                if customButton.id == id {
                    return CustomButtonState(id: id,
                                             enabled: enabled,
                                             visible: customButton.visible,
                                             image: customButton.image,
                                             title: customButton.title)
                } else {
                    return customButton
                }
            }
        case .callScreenHeaderCustomButtonIsVisibleUpdated(let id, let visible):
            callScreenHeaderCustomButtonsState = callScreenHeaderCustomButtonsState.map { (customButton) in
                if customButton.id == id {
                    return CustomButtonState(id: id,
                                             enabled: customButton.enabled,
                                             visible: visible,
                                             image: customButton.image,
                                             title: customButton.title)
                } else {
                    return customButton
                }
            }
        case .callScreenHeaderCustomButtonTitleUpdated(let id, let title):
            callScreenHeaderCustomButtonsState = callScreenHeaderCustomButtonsState.map { (customButton) in
                if customButton.id == id {
                    return CustomButtonState(id: id,
                                             enabled: customButton.enabled,
                                             visible: customButton.visible,
                                             image: customButton.image,
                                             title: title)
                } else {
                    return customButton
                }
            }
        case .callScreenHeaderCustomButtonIconUpdated(let id, let image):
            callScreenHeaderCustomButtonsState = callScreenHeaderCustomButtonsState.map { (customButton) in
                if customButton.id == id {
                    return CustomButtonState(id: id,
                                             enabled: customButton.enabled,
                                             visible: customButton.visible,
                                             image: image,
                                             title: customButton.title)
                } else {
                    return customButton
                }
            }
        }
        return ButtonViewDataState(setupScreenCameraButtonState: setupScreenCameraButtonState,
                                   setupScreenMicButtonState: setupScreenMicButtonState,
                                   setupScreenAudioDeviceButtonState: setupScreenAudioDeviceButtonState,
                                   callScreenCameraButtonState: callScreenCameraButtonState,
                                   callScreenMicButtonState: callScreenMicButtonState,
                                   callScreenAudioDeviceButtonState: callScreenAudioDeviceButtonState,
                                   shareDiagnosticsButton: shareDiagnosticsButton,
                                   reportIssueButton: reportIssueButton,
                                   liveCaptionsButton: liveCaptionsButton,
                                   liveCaptionsToggleButton: liveCaptionsToggleButton,
                                   spokenLanguageButton: spokenLanguageButton,
                                   captionsLanguageButton: captionsLanguageButton,
                                   callScreenCustomButtonsState: callScreenCustomButtonsState,
                                   callScreenHeaderCustomButtonsState: callScreenHeaderCustomButtonsState)
    }
}
