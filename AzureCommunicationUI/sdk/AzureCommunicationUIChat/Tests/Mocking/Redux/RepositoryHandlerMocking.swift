//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUIChat

class RepositoryHandlerMocking: RepositoryMiddlewareHandling {
    var loadInitialMessagesCalled: ((Bool) -> Void)?
    var addReceivedMessageCalled: ((Bool) -> Void)?

    func loadInitialMessages(messages: [ChatMessageInfoModel]) -> Task<Void, Never> {
        Task {
            loadInitialMessagesCalled?(true)
        }
    }

    func addReceivedMessage(message: ChatMessageInfoModel) -> Task<Void, Never> {
        Task {
            addReceivedMessageCalled?(true)
        }
    }
}
