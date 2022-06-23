//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class Store<State>: ObservableObject {

    @Published var state: State

    private var dispatchFunction: ActionDispatch!
    private let reducer: Reducer<State, Actions>
    private let actionDispatchQueue = DispatchQueue(label: "ActionDispatchQueue")

    init(reducer: Reducer<State, Actions>,
         middlewares: [Middleware<State>],
         state: State) {
        self.reducer = reducer
        self.state = state
        self.dispatchFunction = middlewares
            .reversed()
            .reduce({ [unowned self] action in
                self._dispatch(action: action)
            }, { nextDispatch, middleware in
                let dispatch: (Actions) -> Void = { [unowned self] in self.dispatch(action: $0) }
                let getState = { [unowned self] in self.state }
                return middleware.apply(dispatch, getState)(nextDispatch)
            })
    }

    func dispatch(action: Actions) {
        actionDispatchQueue.async {
            self.dispatchFunction(action)
        }
    }

    private func _dispatch(action: Actions) {
        state = reducer.reduce(state, action)
    }
}
