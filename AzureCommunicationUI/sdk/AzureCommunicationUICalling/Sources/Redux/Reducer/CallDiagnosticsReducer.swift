//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

extension Reducer where State == CallDiagnosticsState,
                        Actions == Action {
    static var liveDiagnosticsReducer: Self = Reducer { state, action in
        var networkDiagnostic = state.networkDiagnostic
        var networkQualityDiagnostic = state.networkQualityDiagnostic
        var mediaDiagnostic = state.mediaDiagnostic

        switch action {
        case .userFacingDiagnosticAction(.media(let diagnostic)):
            mediaDiagnostic = diagnostic
        case .userFacingDiagnosticAction(.network(let diagnostic)):
            networkDiagnostic = diagnostic
        case .userFacingDiagnosticAction(.networkQuality(let diagnostic)):
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
