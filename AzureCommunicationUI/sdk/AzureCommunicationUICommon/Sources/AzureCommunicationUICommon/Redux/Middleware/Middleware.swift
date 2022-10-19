//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@_spi(common) public typealias ActionDispatch<Action> = (Action) -> Void

@_spi(common) public struct Middleware<State, Action> {
    public init(apply:
        @escaping (_ actionDispatch: @escaping ActionDispatch<Action>, _ getState: @escaping () -> State) ->
        (@escaping ActionDispatch<Action>) ->
        ActionDispatch<Action>
    ) {
        self.apply = apply
    }
    
    public var apply: (_ actionDispatch: @escaping ActionDispatch<Action>, _ getState: @escaping () -> State) ->
    (@escaping ActionDispatch<Action>) ->
    ActionDispatch<Action>
}
