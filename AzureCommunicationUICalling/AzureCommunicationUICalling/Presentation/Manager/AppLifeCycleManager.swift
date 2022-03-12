//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import Combine

protocol LifeCycleManager {

}

class UIKitAppLifeCycleManager: LifeCycleManager {

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
        let appLifeCycleAction = LifecycleAction.BackgroundEntered()
        store.dispatch(action: appLifeCycleAction)
    }
    @objc func didActivate(_ notification: Notification) {
        logger.debug("Did Activate")

        let appLifeCycleAction = LifecycleAction.ForegroundEntered()
        store.dispatch(action: appLifeCycleAction)
    }
}
