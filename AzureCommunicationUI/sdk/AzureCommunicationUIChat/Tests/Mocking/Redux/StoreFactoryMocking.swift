//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUIChat

class StoreFactoryMocking {
    var store: Store<ChatAppState>!
    var actions = [Action]()
    var firstAction: Action? { return actions.first }
    var didRecordAction: Bool { return !actions.isEmpty }

    init() {
        let middleWare = getMiddleware()
        self.store = Store<ChatAppState>(
            reducer: .mockReducer(),
            middlewares: [middleWare],
            state: ChatAppState()
        )
    }

    func reset() {
        actions = []
    }

    func setState(_ state: ChatAppState) {
        store.state = state
    }

    func getMiddleware() -> Middleware<ChatAppState, AzureCommunicationUIChat.Action> {
        return .mock { [weak self] _, _ in
            return { next in
                return { action in
                    self?.actions.append(action)
                    return next(action)
                }
            }
        }
    }
}
