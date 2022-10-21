//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class SystemMessageViewModel: MessageViewModel {
    var content: String {
        switch message.type {
        case .participantsAdded:
            return "\(participants) joined the chat"
        case .participantsRemoved:
            return "\(participants) left the chat"
        default:
            return "System Message"
        }
    }

    var participants: String {
        return message.participants.map {$0.displayName}
            .joined(separator: ", ")
    }
}
