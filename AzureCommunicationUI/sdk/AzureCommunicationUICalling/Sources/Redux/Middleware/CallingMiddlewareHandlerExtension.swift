//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
extension CallingMiddlewareHandler {
    func handle(error: Error?,
                errorType: CallCompositeInternalError,
                dispatch: @escaping CallActionDispatch) {
        let action: ErrorAction
        if let error = error as? CallCompositeInternalError {
            switch error {
            case .deviceManagerFailed(let internalError):
                action = .fatalErrorUpdated(internalError: error,
                                            error: internalError)
            default:
                action = .fatalErrorUpdated(internalError: error,
                                            error: nil)
            }

        } else {
            action = .fatalErrorUpdated(internalError: errorType,
                                        error: error)
        }
        dispatch(.errorAction(action))
    }

    func handleCallInfo(internalError: CallCompositeInternalError,
                        dispatch: @escaping CallActionDispatch,
                        completion: (() -> Void)? = nil ) {
        let action: ErrorAction
        if internalError == .callTokenFailed {
            action = .fatalErrorUpdated(internalError: internalError,
                                        error: nil)
        } else {
            action = .statusErrorAndCallReset(internalError: internalError,
                                              error: nil)
        }
        dispatch(.errorAction(action))
        completion?()
    }

    func handle(callingStatus: CallingStatus,
                dispatch: @escaping CallActionDispatch) {
        dispatch(.callingAction(.stateUpdated(status: callingStatus)))

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
            dispatch(.callingViewLaunched)
        }
    }
}
