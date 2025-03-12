//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

extension Reducer where State == CallDiagnosticsState,
                        Actions == Action {
    static var liveDiagnosticsReducer: Self = Reducer { state, action in
        var networkDiagnostic: NetworkDiagnosticModel?
        var networkQualityDiagnostic: NetworkQualityDiagnosticModel?
        var mediaDiagnostic: MediaDiagnosticModel?

        switch action {
        case .callDiagnosticAction(.media(let diagnosticModel)):
            mediaDiagnostic = diagnosticModel
        case .callDiagnosticAction(.network(let diagnosticModel)):
            networkDiagnostic = diagnosticModel
        case .callDiagnosticAction(.networkQuality(let diagnosticModel)):
            networkQualityDiagnostic = diagnosticModel
        case .callDiagnosticAction(.dismissNetworkQuality(let diagnostic)):
            if diagnostic == state.networkQualityDiagnostic?.diagnostic {
                networkQualityDiagnostic = nil
            }
        case .callDiagnosticAction(.dismissNetwork(let diagnostic)):
            if diagnostic == state.networkDiagnostic?.diagnostic {
                networkDiagnostic = nil
            }
        case .callDiagnosticAction(.dismissMedia(let diagnostic)):
            if diagnostic == state.mediaDiagnostic?.diagnostic {
                mediaDiagnostic = nil
            }
        // Exhaustive unimplemented actions
        case .audioSessionAction,
             .callingAction,
             .lifecycleAction,
             .localUserAction,
             .permissionAction,
             .remoteParticipantsAction,
             .errorAction,
             .compositeExitAction,
             .callingViewLaunched,
             .showSupportForm,
             .showCaptionsRttListView,
             .showSpokenLanguageView,
             .showCaptionsLanguageView,
             .captionsAction,
             .rttAction,
             .showEndCallConfirmation,
             .showMoreOptions,
             .showAudioSelection,
             .showSupportShare,
             .showParticipants,
             .showParticipantActions,
             .hideDrawer,
             .visibilityAction,
             .toastNotificationAction,
             .callScreenInfoHeaderAction,
             .setTotalParticipantCount,
             .buttonViewDataAction:
            return state
        }
        return CallDiagnosticsState(networkDiagnostic: networkDiagnostic,
                                    networkQualityDiagnostic: networkQualityDiagnostic,
                                    mediaDiagnostic: mediaDiagnostic)
    }
}
