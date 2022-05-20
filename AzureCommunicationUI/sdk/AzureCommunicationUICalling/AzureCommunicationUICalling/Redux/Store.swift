//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class Store<T: ReduxState>: ObservableObject {

    @Published var state: T

    private var dispatchFunction: ActionDispatch!
    private let reducer: Reducer
    private let actionDispatchQueue = DispatchQueue(label: "ActionDispatchQueue")

    init(reducer: Reducer,
         middlewares: [Middleware],
         state: T) {
        self.reducer = reducer
        self.state = state
        self.dispatchFunction = middlewares
            .reversed()
            .reduce({ [unowned self] action in
                self._dispatch(action: action)
            }, { nextDispatch, middleware in
                let dispatch: (Action) -> Void = { [weak self] in self?.dispatch(action: $0) }
                let getState = { [weak self] in self?.state }
                return middleware.apply(dispatch: dispatch, getState: getState)(nextDispatch)
            })
    }

    func dispatch(action: Action) {
        actionDispatchQueue.async {
            self.dispatchFunction(action)
        }
    }

    private func _dispatch(action: Action) {
        guard let newState = reducer.reduce(state, action) as? T else {
            return
        }
        state = newState
    }
}
