//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUIChat

class RepositoryHandlerMocking: RepositoryMiddlewareHandling {
    var loadInitialMessagesCalled: ((Bool) -> Void)?
    var addNewSentMessageCalled: ((Bool) -> Void)?
    var updateSentMessageIdCalled: ((Bool) -> Void)?
    var addReceivedMessageCalled: ((Bool) -> Void)?

    func loadInitialMessages(messages: [ChatMessageInfoModel], state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            loadInitialMessagesCalled?(true)
        }
    }

    func addNewSentMessage(internalId: String, content: String, state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            addNewSentMessageCalled?(true)
        }
    }

    func updateSentMessageId(internalId: String, actualId: String, state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            updateSentMessageIdCalled?(true)
        }
    }

    func addReceivedMessage(message: ChatMessageInfoModel, state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            addReceivedMessageCalled?(true)
        }
    }
}
