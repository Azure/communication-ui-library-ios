//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

typealias ActionDispatch = (Action) -> Void

struct Middleware<State> {
    var apply: (_ actionDispatch: @escaping ActionDispatch, _ getState: @escaping () -> State) ->
    (@escaping ActionDispatch) ->
    ActionDispatch
}
