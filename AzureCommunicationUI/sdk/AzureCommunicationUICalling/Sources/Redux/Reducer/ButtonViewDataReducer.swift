//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

extension Reducer where State == ButtonViewDataState,
                        Actions == Action {
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

        switch action {
        case .buttonViewDataAction(.setupScreenAudioDeviceButtonIsEnabledUpdated(let enabled)):
            guard let fromState = setupScreenAudioDeviceButtonState else {
                return state
            }
            setupScreenAudioDeviceButtonState = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .buttonViewDataAction(.setupScreenAudioDeviceButtonIsVisibleUpdated(let visible)):
            guard let fromState = setupScreenAudioDeviceButtonState else {
                return state
            }
            setupScreenAudioDeviceButtonState = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .buttonViewDataAction(.setupScreenMicButtonIsEnabledUpdated(let enabled)):
            guard let fromState = setupScreenMicButtonState else {
                return state
            }
            setupScreenMicButtonState = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .buttonViewDataAction(.setupScreenMicButtonIsVisibleUpdated(let visible)):
            guard let fromState = setupScreenMicButtonState else {
                return state
            }
            setupScreenMicButtonState = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .buttonViewDataAction(.setupScreenCameraButtonIsEnabledUpdated(let enabled)):
            guard let fromState = setupScreenCameraButtonState else {
                return state
            }
            setupScreenCameraButtonState = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .buttonViewDataAction(.setupScreenCameraButtonIsVisibleUpdated(let visible)):
            guard let fromState = setupScreenCameraButtonState else {
                return state
            }
            setupScreenCameraButtonState = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .buttonViewDataAction(.callScreenAudioDeviceButtonIsEnabledUpdated(let enabled)):
            guard let fromState = callScreenAudioDeviceButtonState else {
                return state
            }
            callScreenAudioDeviceButtonState = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .buttonViewDataAction(.callScreenAudioDeviceButtonIsVisibleUpdated(let visible)):
            guard let fromState = callScreenAudioDeviceButtonState else {
                return state
            }
            callScreenAudioDeviceButtonState = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .buttonViewDataAction(.callScreenMicButtonIsEnabledUpdated(let enabled)):
            guard let fromState = callScreenMicButtonState else {
                return state
            }
            callScreenMicButtonState = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .buttonViewDataAction(.callScreenMicButtonIsVisibleUpdated(let visible)):
            guard let fromState = callScreenMicButtonState else {
                return state
            }
            callScreenMicButtonState = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .buttonViewDataAction(.callScreenCameraButtonIsEnabledUpdated(let enabled)):
            guard let fromState = callScreenCameraButtonState else {
                return state
            }
            callScreenCameraButtonState = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .buttonViewDataAction(.callScreenCameraButtonIsVisibleUpdated(let visible)):
            guard let fromState = callScreenCameraButtonState else {
                return state
            }
            callScreenCameraButtonState = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .buttonViewDataAction(.callScreenReportIssueButtonIsEnabledUpdated(let enabled)):
            guard let fromState = reportIssueButton else {
                return state
            }
            reportIssueButton = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .buttonViewDataAction(.callScreenReportIssueButtonIsVisibleUpdated(let visible)):
            guard let fromState = reportIssueButton else {
                return state
            }
            reportIssueButton = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .buttonViewDataAction(.callScreenShareDiagnosticsButtonIsEnabledUpdated(let enabled)):
            guard let fromState = shareDiagnosticsButton else {
                return state
            }
            shareDiagnosticsButton = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .buttonViewDataAction(.callScreenShareDiagnosticsButtonIsVisibleUpdated(let visible)):
            guard let fromState = shareDiagnosticsButton else {
                return state
            }
            shareDiagnosticsButton = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .buttonViewDataAction(.callScreenLiveCaptionsButtonIsEnabledUpdated(let enabled)):
            guard let fromState = liveCaptionsButton else {
                return state
            }
            liveCaptionsButton = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .buttonViewDataAction(.callScreenLiveCaptionsButtonIsVisibleUpdated(let visible)):
            guard let fromState = liveCaptionsButton else {
                return state
            }
            liveCaptionsButton = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .buttonViewDataAction(.callScreenLiveCaptionsToggleButtonIsEnabledUpdated(let enabled)):
            guard let fromState = liveCaptionsToggleButton else {
                return state
            }
            liveCaptionsToggleButton = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .buttonViewDataAction(.callScreenLiveCaptionsToggleButtonIsVisibleUpdated(let visible)):
            guard let fromState = liveCaptionsToggleButton else {
                return state
            }
            liveCaptionsToggleButton = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .buttonViewDataAction(.callScreenSpokenLanguageButtonIsEnabledUpdated(let enabled)):
            guard let fromState = spokenLanguageButton else {
                return state
            }
            spokenLanguageButton = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .buttonViewDataAction(.callScreenSpokenLanguageButtonIsVisibleUpdated(let visible)):
            guard let fromState = spokenLanguageButton else {
                return state
            }
            spokenLanguageButton = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .buttonViewDataAction(.callScreenCaptionsLanguageButtonIsEnabledUpdated(let enabled)):
            guard let fromState = captionsLanguageButton else {
                return state
            }
            captionsLanguageButton = DefaultButtonState(enabled: enabled, visible: fromState.visible)
        case .buttonViewDataAction(.callScreenCaptionsLanguageButtonIsVisibleUpdated(let visible)):
            guard let fromState = captionsLanguageButton else {
                return state
            }
            captionsLanguageButton = DefaultButtonState(enabled: fromState.enabled, visible: visible)

        case .buttonViewDataAction(.callScreenCustomButtonIsEnabledUpdated(let id, let enabled)):
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
        case .buttonViewDataAction(.callScreenCustomButtonIsVisibleUpdated(let id, let visible)):
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

        // Exhaustive unimplemented actions
        case .audioSessionAction,
             .callingAction,
             .lifecycleAction,
             .localUserAction,
             .permissionAction,
             .remoteParticipantsAction,
             .callDiagnosticAction,
             .errorAction,
             .compositeExitAction,
             .callingViewLaunched,
             .showSupportForm,
             .showCaptionsListView,
             .showSpokenLanguageView,
             .showCaptionsLanguageView,
             .captionsAction,
             .showEndCallConfirmation,
             .showMoreOptions,
             .showAudioSelection,
             .showSupportShare,
             .showParticipants,
             .showParticipantActions,
             .hideDrawer,
             .visibilityAction,
             .toastNotificationAction,
             /* <TIMER_TITLE_FEATURE> */
             .callScreenInfoHeaderAction,
             /* </TIMER_TITLE_FEATURE> */
             .setTotalParticipantCount,
             .buttonViewDataAction:
            return state
        }

        return ButtonViewDataState(setupScreenCameraButtonState: setupScreenCameraButtonState,
                                   setupScreenMicButtonState: setupScreenMicButtonState,
                                   setupScreenAudioDeviceButtonState: setupScreenAudioDeviceButtonState,
                                   callScreenCameraButtonState: callScreenCameraButtonState,
                                   callScreenMicButtonState: callScreenMicButtonState,
                                   callScreenAudioDeviceButtonState: callScreenAudioDeviceButtonState,
                                   liveCaptionsButton: liveCaptionsButton,
                                   liveCaptionsToggleButton: liveCaptionsToggleButton,
                                   spokenLanguageButton: spokenLanguageButton,
                                   captionsLanguageButton: captionsLanguageButton,
                                   shareDiagnosticsButton: shareDiagnosticsButton,
                                   reportIssueButton: reportIssueButton,
                                   callScreenCustomButtonsState: callScreenCustomButtonsState)
    }
}
