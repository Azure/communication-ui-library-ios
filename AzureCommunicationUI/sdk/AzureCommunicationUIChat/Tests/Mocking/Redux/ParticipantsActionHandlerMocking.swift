//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class ParticipantsActionHandlerMocking: ParticipantsActionHandling {
    var sendReadReceiptCalled: ((Bool) -> Void)?

    func sendReadReceipt(
              messageId: String,
              dispatch: @escaping AzureCommunicationUIChat.ActionDispatch) -> Task<Void, Never> {
        Task {
            sendReadReceiptCalled?(true)
        }
    }
}
