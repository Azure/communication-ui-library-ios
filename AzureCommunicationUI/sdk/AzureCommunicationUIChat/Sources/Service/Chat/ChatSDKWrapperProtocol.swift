//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationChat

protocol ChatSDKWrapperProtocol {
    func chatStart() async throws -> [ChatMessageInfoModel]

    var chatEventsHandler: ChatSDKEventsHandling { get }
}
