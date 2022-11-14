//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class SystemMessageViewModel: MessageViewModel {
    var content: String {
        switch message.type {
        case .participantsAdded:
            return "\(participants) joined the chat" // Localization
        case .participantsRemoved:
            return "\(participants) left the chat" // Localization
        case .topicUpdated:
            return "Topic updated \(message.content ?? "")" // Localization
        case .localUserRemoved:
            return "You were removed from the chat" // todo: Localization
        default:
            return "System Message"
        }
    }

    var participants: String {
        return message.participants.map {$0.displayName}
            .joined(separator: ", ")
    }
}
