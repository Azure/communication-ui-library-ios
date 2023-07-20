//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Network
import Combine

protocol NetworkManagerProtocol {}

class NetworkManager: NetworkManagerProtocol, ObservableObject {
    @Published var isConnected: Bool = true
    private enum Constant {
        static let networkQueue: String = "NetworkMonitorQueue"
    }

    private var monitor: NWPathMonitor?
    private let networkMonitorQueue: DispatchQueue

    init() {
        networkMonitorQueue = DispatchQueue(label: Constant.networkQueue)
    }

    func startMonitor() {
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { [weak self] path in
                    DispatchQueue.main.async {
                        self?.isConnected = path.status == .satisfied
                    }
                }
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
