//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationChat
import Combine

protocol ChatSDKWrapperProtocol {
    func initializeChat() async throws
    func getInitialMessages() async throws -> [ChatMessageInfoModel]

    var chatEventsHandler: ChatSDKEventsHandling { get }
}
