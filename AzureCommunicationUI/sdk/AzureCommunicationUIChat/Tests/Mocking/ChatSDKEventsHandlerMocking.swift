//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import AzureCommunicationChat
@testable import AzureCommunicationUIChat

class ChatSDKEventsHandlerMocking: NSObject, ChatSDKEventsHandling {
    var chatEventSubject = PassthroughSubject<ChatEventModel, Never>()

    func handle(response: TrouterEvent) {}
}
