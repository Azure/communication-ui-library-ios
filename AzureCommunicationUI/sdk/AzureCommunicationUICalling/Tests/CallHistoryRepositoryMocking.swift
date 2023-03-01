//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class CallHistoryRepositoryMocking: CallHistoryRepository {
    var insertCallCount: Int = 0

    init() {
        super.init(logger: LoggerMocking(),
                   userDefaults: UserDefaultsStorageMocking(data: {_ in return nil }, set: {_, _ in }))
    }

    override func insert(callStartedOn: Date, callId: String) {
        insertCallCount += 1
    }

    func insertWasCalled() -> Bool {
        return insertCallCount > 0
    }

    override func getAll() -> [AzureCommunicationUICalling.CallHistoryRecord] {
        return []
    }
}
