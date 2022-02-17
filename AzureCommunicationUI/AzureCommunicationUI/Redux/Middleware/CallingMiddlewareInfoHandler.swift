//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
extension CallingMiddlewareHandler {
    func handle(error: Error, errorCode: String, dispatch: @escaping ActionDispatch) {
        let compositeError = ErrorEvent(code: errorCode, error: error)
        let action = ErrorAction.FatalErrorUpdated(error: compositeError)
        dispatch(action)
    }

    func handleInfo(errorCode: String, dispatch: @escaping ActionDispatch) {
        let action: Action
        let error = ErrorEvent(code: errorCode, error: nil)
        if errorCode == CallCompositeErrorCode.tokenExpired {
            action = ErrorAction.FatalErrorUpdated(error: error)
        } else {
            action = ErrorAction.StatusErrorAndCallReset(error: error)
        }

        dispatch(action)

    }

    func handleInfo(callingStatus: CallingStatus, dispatch: @escaping ActionDispatch) {
        let action = CallingAction.StateUpdated(status: callingStatus)
        switch callingStatus {
        case .none,
            .earlyMedia,
            .connecting,
            .ringing,
            .localHold,
            .disconnecting,
            .remoteHold,
            .disconnected:
            break
        case .connected,
             .inLobby:
            dispatch(CallingViewLaunched())
        }
        dispatch(action)

    }
}
