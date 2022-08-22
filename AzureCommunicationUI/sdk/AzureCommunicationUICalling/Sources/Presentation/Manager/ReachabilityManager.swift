//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Network

protocol ReachabilityManagerProtocol {}

class ReachabilityManager: ReachabilityManagerProtocol {

    private let store: Store<AppState>
    private let logger: Logger
    private let monitor = NWPathMonitor()
    private let networkMonitorQueue = DispatchQueue(label: "NetworkMonitorQueue")

    init(store: Store<AppState>,
         logger: Logger) {
        self.store = store
        self.logger = logger
        monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                logger.debug("Network Connection: Offline")
                store.dispatch(action: .networkAction(.networkLost))
            } else if path.status == .satisfied {
                logger.debug("Network Connection: Online")
                store.dispatch(action: .networkAction(.networkRestored))
            }
        }
        monitor.start(queue: networkMonitorQueue)
    }
}
