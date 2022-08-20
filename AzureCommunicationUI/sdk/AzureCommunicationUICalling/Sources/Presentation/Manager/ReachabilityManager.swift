//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Network

protocol ReachabilityManagerProtocol {}

class ReachabilityManager: ReachabilityManagerProtocol {

    private let store: Store<AppState>
    private let monitor = NWPathMonitor()
    private let networkMonitorQueue = DispatchQueue(label: "NetworkMonitorQueue")

    init(store: Store<AppState>) {
        self.store = store
        monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                #warning("remove debug messages here")
                print("network lost detected")
                store.dispatch(action: .errorAction(.networkLost))
            }
            print("network mointor closure ends with path = \(path.status)")
        }
        print("manager done set up")
        monitor.start(queue: networkMonitorQueue)
    }
}
