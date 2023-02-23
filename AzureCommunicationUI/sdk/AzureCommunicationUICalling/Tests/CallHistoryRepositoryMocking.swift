//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class CallHistoryRepositoryMocking: CallHistoryRepositoryProtocol {
    var insertCallCount: Int = 0
    func insert(callStartedOn: Date, callId: String) {
        insertCallCount += 1
    }

    func insertWasCalled() -> Bool {
        return insertCallCount > 0
    }

    func getAll() -> [AzureCommunicationUICalling.CallHistoryRecord] {
        return []
    }
}
