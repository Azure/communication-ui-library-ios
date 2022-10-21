//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ParticipantsAction: Equatable {
    // MARK: - Chat SDK Local Event Actions
    case leaveChatSuccess

    // MARK: - Chat SDK Remote Event Actions
    case typingIndicatorReceived(id: String, timer: Timer)
    case clearTypingIndicator(id: String)
    case participantsAdded(participants: [ParticipantInfoModel])
    case participantsRemoved(participants: [ParticipantInfoModel])
}
