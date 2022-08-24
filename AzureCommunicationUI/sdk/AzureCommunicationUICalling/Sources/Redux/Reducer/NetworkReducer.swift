//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension Reducer where State == NetworkState,
                        Actions == NetworkAction {
    static var liveNetworkReducer: Self = Reducer { networkState, action in
        var status = networkState.status
        switch action {
        case .networkRestored:
            status = .online
        case .networkLost:
            status = .offline
        }
        return NetworkState(status)
    }
}
