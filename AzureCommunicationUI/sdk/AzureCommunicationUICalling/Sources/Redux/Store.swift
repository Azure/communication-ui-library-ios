//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

typealias ActionDispatch = CommonActionDispatch<Action>
class Store<State>: ObservableObject {

    @Published var state: State

    private var dispatchFunction: ActionDispatch!
    private let reducer: Reducer<State, Action>
    private let actionDispatchQueue = DispatchQueue(label: "ActionDispatchQueue")

    init(reducer: Reducer<State, Action>,
         middlewares: [Middleware<State, Action>],
         state: State) {
        self.reducer = reducer
        self.state = state
        self.dispatchFunction = middlewares
            .reversed()
            .reduce({ [unowned self] action in
                self._dispatch(action: action)
            }, { nextDispatch, middleware in
                let dispatch: (Action) -> Void = { [weak self] in self?.dispatch(action: $0) }
                let getState = { [unowned self] in self.state }
                return middleware.apply(dispatch, getState)(nextDispatch)
            })
    }

    func dispatch(action: Action) {
        actionDispatchQueue.async {
            self.dispatchFunction(action)
        }
    }

    private func _dispatch(action: Action) {
        state = reducer.reduce(state, action)
    }
}

extension Store where State == AppState {
    static func constructStore(
        logger: Logger,
        callingService: CallingServiceProtocol,
        displayName: String?
    ) -> Store<AppState> {
        let localUserState = LocalUserState(displayName: displayName)

        return Store<AppState>(
            reducer: Reducer<AppState, Action>.appStateReducer(),
            middlewares: [
                Middleware<AppState, Action>.liveCallingMiddleware(
                    callingMiddlewareHandler: CallingMiddlewareHandler(
                        callingService: callingService,
                        logger: logger
                    )
                )
            ],
            state: AppState(localUserState: localUserState)
        )
    }
}
