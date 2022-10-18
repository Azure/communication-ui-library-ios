//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Combine
import Foundation
import UIKit

protocol LifeCycleManagerProtocol {

}

class UIKitAppLifeCycleManager: LifeCycleManagerProtocol {

    private let logger: Logger
    private let store: Store<AppState>

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState>,
         logger: Logger) {
        self.logger = logger
        self.store = store
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willDeactivate),
                                               name: UIScene.willDeactivateNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didActivate),
                                               name: UIScene.didActivateNotification,
                                               object: nil)
    }

    @objc func willDeactivate(_ notification: Notification) {
        logger.debug("Will Deactivate")
        store.dispatch(action: .lifecycleAction(.backgroundEntered))
    }

    @objc func didActivate(_ notification: Notification) {
        logger.debug("Did Activate")
        store.dispatch(action: .lifecycleAction(.foregroundEntered))
    }
}
