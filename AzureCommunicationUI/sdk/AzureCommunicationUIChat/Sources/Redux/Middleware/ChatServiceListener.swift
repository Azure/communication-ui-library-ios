//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import AzureCommunicationCommon

protocol ChatServiceListening {
    func subscription(dispatch: @escaping ActionDispatch)
}

class ChatServiceListener: ChatServiceListening {
    private let chatService: ChatServiceProtocol
    private let logger: Logger
    private let cancelBag = CancelBag()
    private let subscription = CancelBag()

    init(chatService: ChatServiceProtocol, logger: Logger) {
        self.chatService = chatService
        self.logger = logger
    }

    func subscription(dispatch: @escaping ActionDispatch) {
        logger.debug("Subscribe to calling service subjects")
    }
}
