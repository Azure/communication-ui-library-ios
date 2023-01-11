//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

typealias CommonActionDispatch<A> = (A) -> Void

struct Middleware<State, Action> {
    var apply: (_ actionDispatch: @escaping CommonActionDispatch<Action>, _ getState: @escaping () -> State) ->
    (@escaping CommonActionDispatch<Action>) ->
    CommonActionDispatch<Action>
}
