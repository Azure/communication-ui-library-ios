//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Network

protocol NetworkManagerProtocol {}

class NetworkManager: NetworkManagerProtocol {

    private enum Constant {
        static let networkQueue: String = "NetworkMonitorQueue"
    }

    private let monitor: NWPathMonitor
    private let networkMonitorQueue: DispatchQueue

    init() {
        monitor = NWPathMonitor()
        networkMonitorQueue = DispatchQueue(label: Constant.networkQueue)
    }

    func isOnline() -> Bool {
        return monitor.currentPath.status == .satisfied
    }

    func startMonitor() {
        monitor.start(queue: networkMonitorQueue)
    }

    func stopMonitor() {
        monitor.cancel()
    }
}
