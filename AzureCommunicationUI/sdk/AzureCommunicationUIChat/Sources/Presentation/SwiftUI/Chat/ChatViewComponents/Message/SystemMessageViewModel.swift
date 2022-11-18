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
            if message.isLocalUser {
                return "You were removed from the chat" // todo: Localization
            }
            return "\(participants) left the chat" // Localization
        case .topicUpdated:
            return "Topic updated \(message.content ?? "")" // Localization
        default:
            return "System Message"
        }
    }

    var participants: String {
        return message.participants.map {$0.displayName}
            .joined(separator: ", ")
    }

    var icon: CompositeIcon? {
        switch message.type {
        case .participantsAdded:
            return .systemJoin
        case .participantsRemoved:
            return .systemLeave
        case .topicUpdated:
            return nil
        default:
            return nil
        }
    }
}
