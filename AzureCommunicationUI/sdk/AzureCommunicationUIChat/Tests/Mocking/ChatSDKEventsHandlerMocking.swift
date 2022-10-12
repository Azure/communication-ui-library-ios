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
    var typingIndicatorReceived: Bool = false

    func handle(response: TrouterEvent) {
        switch response {
        case .typingIndicatorReceived(_):
            typingIndicatorReceived = true
        default:
            print("Event received will not handled \(response)")
        }
    }
}
