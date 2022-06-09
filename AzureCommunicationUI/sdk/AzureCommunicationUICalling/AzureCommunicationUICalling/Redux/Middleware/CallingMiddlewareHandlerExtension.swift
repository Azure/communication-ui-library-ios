//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
extension CallingMiddlewareHandler {
    func handle(error: Error?,
                errorType: CallCompositeInternalError,
                dispatch: @escaping ActionDispatch) {
        let action: Action
        if let error = error as? CallCompositeInternalError {
            action = ErrorAction.FatalErrorUpdated(internalError: error,
                                                   error: nil)
        } else {
            action = ErrorAction.FatalErrorUpdated(internalError: errorType,
                                                   error: error)
        }
        dispatch(action)
    }

    func handleCallInfo(internalError: CallCompositeInternalError,
                        dispatch: @escaping ActionDispatch,
                        completion: (() -> Void)? = nil ) {
        let action: Action
        if internalError == .callTokenFailed {
            action = ErrorAction.FatalErrorUpdated(internalError: internalError,
                                                   error: nil)
        } else {
            action = ErrorAction.StatusErrorAndCallReset(internalError: internalError,
                                                         error: nil)
        }
        dispatch(action)
        completion?()
    }

    func handle(callingStatus: CallingStatus,
                dispatch: @escaping ActionDispatch) {
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
