//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
extension CallingMiddlewareHandler {
    func handle(error: Error, errorCode: String, dispatch: @escaping ActionDispatch) {
        let compositeError = CallCompositeErrorEvent(code: errorCode, error: error)
        let action = ErrorAction.FatalErrorUpdated(error: compositeError)
        dispatch(action)
    }

    func handle(errorCode: String, dispatch: @escaping ActionDispatch, completion: (() -> Void)? = nil ) {
        guard !errorCode.isEmpty else {
            return
        }
        let action: Action
        let error = CallCompositeErrorEvent(code: errorCode, error: nil)
        if errorCode == CallCompositeErrorCode.tokenExpired {
            action = ErrorAction.FatalErrorUpdated(error: error)
        } else {
            action = ErrorAction.StatusErrorAndCallReset(error: error)
        }

        dispatch(action)
        completion?()
    }

    func handle(callingStatus: CallingStatus, dispatch: @escaping ActionDispatch) {
        dispatch(CallingAction.StateUpdated(status: callingStatus))

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

    }
}
