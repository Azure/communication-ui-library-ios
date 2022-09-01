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

    private var monitor: NWPathMonitor?
    private let networkMonitorQueue: DispatchQueue

    init() {
        networkMonitorQueue = DispatchQueue(label: Constant.networkQueue)
    }

    func isOnline() -> Bool {
        return monitor?.currentPath.status == .satisfied
    }

    func startMonitor() {
        monitor = NWPathMonitor()
        monitor?.start(queue: networkMonitorQueue)
    }

    func stopMonitor() {
        // once monitor is cancelled
        // its path object is gone
        // need to init monitor again at line 28
        // https://developer.apple.com/forums/thread/124486
        monitor?.cancel()
    }
}
