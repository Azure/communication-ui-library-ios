//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
#if canImport(AzureCommunicationUICalling)
@testable import AzureCommunicationUICalling
#elseif canImport(AzureCommunicationUIChat)
@testable import AzureCommunicationUIChat
#endif

class StoreFactoryMocking {
    var store: Store<AppState>!
    var actions = [Action]()
    var firstAction: Action? { return actions.first }
    var didRecordAction: Bool { return !actions.isEmpty }

    init() {
        let middleWare = getMiddleware()
        self.store = Store<AppState>(
            reducer: .mockReducer(),
            middlewares: [middleWare],
            state: AppState()
        )
    }

    func reset() {
        actions = []
    }

    func setState(_ state: AppState) {
        store.state = state
    }

    func getMiddleware() -> Middleware<AppState> {
        return Middleware<AppState>.mock { [weak self] _, _ in
            return { next in
                return { action in
                    self?.actions.append(action)
                    return next(action)
                }
            }
        }
    }
}
