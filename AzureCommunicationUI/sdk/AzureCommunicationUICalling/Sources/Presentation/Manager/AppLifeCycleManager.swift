//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import UIKit

protocol LifeCycleManagerProtocol {

}

class UIKitAppLifeCycleManager: LifeCycleManagerProtocol {

    private let logger: Logger
    private let store: Store<AppState, Action>
    private var operationStatus: OperationStatus
    private var callingStatus: CallingStatus
    private var runLoop: CFRunLoop?

    var cancellables = Set<AnyCancellable>()

    init(store: Store<AppState, Action>,
         logger: Logger) {
        self.logger = logger
        self.store = store
        self.operationStatus = .none
        self.callingStatus = .none
        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state: state)
            }.store(in: &cancellables)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willDeactivate),
                                               name: UIScene.willDeactivateNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didActivate),
                                               name: UIScene.didActivateNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }

    private func receive(state: AppState) {
        update(callingState: state.callingState)
    }

    private func update(callingState: CallingState) {
        callingStatus = callingState.status
        let newOperationStatus = callingState.operationStatus
        guard operationStatus != newOperationStatus else {
            return
        }
        operationStatus = newOperationStatus

        if operationStatus == .callEnded,
           let currentRunloop = runLoop {
            CFRunLoopStop(currentRunloop)
        }

    }

    @objc func willDeactivate(_ notification: Notification) {
        logger.debug("Will Deactivate")
        store.dispatch(action: .lifecycleAction(.backgroundEntered))
    }

    @objc func didActivate(_ notification: Notification) {
        logger.debug("Did Activate")
        store.dispatch(action: .lifecycleAction(.foregroundEntered))
    }

    @objc func willTerminate(_ notification: Notification) {
        logger.debug("Will Terminate")
        store.dispatch(action: .lifecycleAction(.willTerminate))
        if callingStatus == .connected {
            self.runLoop = CFRunLoopGetCurrent()
            CFRunLoopRun()
        }
    }
}
