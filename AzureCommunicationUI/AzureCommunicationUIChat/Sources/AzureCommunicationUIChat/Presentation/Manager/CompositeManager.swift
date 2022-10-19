//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation

protocol CompositeManagerProtocol {
    func start()
    func stop(completionHandler: @escaping (() -> Void))
}

class CompositeManager: CompositeManagerProtocol {
    private let logger: Logger
    private let store: Store<AppState, Action>

    private var compositeCompletionHandler: (() -> Void)?

    init(store: Store<AppState, Action>,
         logger: Logger) {
        self.logger = logger
        self.store = store
    }

    func start() {
        store.dispatch(action: .chatAction(.initializeChatTriggered))
    }

    func stop(completionHandler: @escaping (() -> Void)) {
        store.dispatch(action: .compositeExitAction)
        compositeCompletionHandler = completionHandler
    }
}
