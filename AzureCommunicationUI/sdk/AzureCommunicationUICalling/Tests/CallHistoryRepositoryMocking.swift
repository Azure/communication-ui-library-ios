//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class CallHistoryRepositoryMocking: CallHistoryRepository {
    var insertCallCount: Int = 0

    init(userDefaults: UserDefaults) {
        super.init(logger: LoggerMocking(),
                   userDefaults: userDefaults)
    }

    override func insert(callStartedOn: Date, callId: String) async -> Error? {
        insertCallCount += 1
        return nil
    }

    func insertWasCalled() -> Bool {
        return insertCallCount > 0
    }

    override func getAll() -> [AzureCommunicationUICalling.CallHistoryRecord] {
        return []
    }
}
