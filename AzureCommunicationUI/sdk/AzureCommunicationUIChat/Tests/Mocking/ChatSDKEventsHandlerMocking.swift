//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationChat
@testable import AzureCommunicationUIChat

class ChatSDKEventsHandlerMocking: NSObject, ChatSDKEventsHandling {
    func handle(response: TrouterEvent) {}
}
