//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
extension CallingMiddlewareHandler {
    func handle(error: Error?,
                errorType: CallCompositeInternalError,
                dispatch: @escaping ActionDispatch) {
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
                        dispatch: @escaping ActionDispatch,
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

    func handle(callInfoModel: CallInfoModel,
                dispatch: @escaping ActionDispatch,
                callType: CompositeCallType) {
        dispatch(.callingAction(.stateUpdated(status: callInfoModel.status,
                                              callEndReasonCode: callInfoModel.callEndReasonCode,
                                              callEndReasonSubCode: callInfoModel.callEndReasonSubCode)))
        let activeStatuses: [CallingStatus] = callType == .oneToNOutgoing ?
        [.connected, .ringing, .connecting] : [.connected, .inLobby]

        if activeStatuses.contains(callInfoModel.status) {
            dispatch(.callingViewLaunched)
        }
    }
}
