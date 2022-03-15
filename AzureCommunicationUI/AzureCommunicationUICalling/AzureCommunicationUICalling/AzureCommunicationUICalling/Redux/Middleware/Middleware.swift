//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

typealias ActionDispatch = (Action) -> Void

protocol Middleware {
    func apply(dispatch: @escaping ActionDispatch,
               getState: @escaping () -> ReduxState?) -> (@escaping ActionDispatch) -> ActionDispatch
}
