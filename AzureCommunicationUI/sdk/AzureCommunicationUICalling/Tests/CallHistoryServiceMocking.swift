//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class CallHistoryServiceMocking: CallHistoryService {
    var recordCallHistoryCallCount: Int = 0

    override func recordCallHistory(callStartedOn: Date, callId: String) {
        recordCallHistoryCallCount += 1
    }

    func recordCallHistoryWasCalled() -> Bool {
        return recordCallHistoryCallCount > 0
    }
}
