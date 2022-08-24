//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum NetworkStatus {
    case online, offline
}

struct NetworkState {
    let status: NetworkStatus

    init(_ status: NetworkStatus = .online) {
        self.status = status
    }
}
