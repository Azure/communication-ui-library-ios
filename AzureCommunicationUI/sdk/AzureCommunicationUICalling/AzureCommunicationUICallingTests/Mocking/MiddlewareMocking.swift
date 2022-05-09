//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

struct MiddlewareMocking: Middleware {

    let closure: (@escaping ActionDispatch, @escaping () -> ReduxState?) -> (@escaping ActionDispatch) -> ActionDispatch

    init(applyingClosure: @escaping (
        @escaping ActionDispatch,
        @escaping () -> ReduxState?) -> (@escaping ActionDispatch) -> ActionDispatch) {
        self.closure = applyingClosure
    }

    func apply(dispatch: @escaping ActionDispatch,
               getState: @escaping () -> ReduxState?) -> (@escaping ActionDispatch) -> ActionDispatch {
        return closure(dispatch, getState)
    }

}
