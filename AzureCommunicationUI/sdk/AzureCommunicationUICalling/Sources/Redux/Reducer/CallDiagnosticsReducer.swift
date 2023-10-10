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
        case .callDiagnosticAction(.media(let diagnostic)):
            mediaDiagnostic = diagnostic
        case .callDiagnosticAction(.network(let diagnostic)):
            networkDiagnostic = diagnostic
        case .callDiagnosticAction(.networkQuality(let diagnostic)):
            networkQualityDiagnostic = diagnostic
        // Exhaustive unimplemented actions
        case .audioSessionAction(_),
             .callingAction(_),
             .lifecycleAction(_),
             .localUserAction(_),
             .permissionAction(_),
             .remoteParticipantsAction(_),
             .errorAction(_),
             .compositeExitAction,
             .callingViewLaunched:
            return state
        }

        return CallDiagnosticsState(networkDiagnostic: networkDiagnostic,
                                    networkQualityDiagnostic: networkQualityDiagnostic,
                                    mediaDiagnostic: mediaDiagnostic)
    }
}
