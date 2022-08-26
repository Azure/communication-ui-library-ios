//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum NetworkStatus {
    case online
    case offline
    case unknown
}

struct NetworkState {
    let status: NetworkStatus

    init(_ status: NetworkStatus = .unknown) {
        self.status = status
    }
}
