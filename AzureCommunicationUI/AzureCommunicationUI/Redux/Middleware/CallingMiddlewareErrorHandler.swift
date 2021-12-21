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
}
