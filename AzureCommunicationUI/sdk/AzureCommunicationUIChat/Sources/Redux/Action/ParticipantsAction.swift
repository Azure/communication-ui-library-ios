//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ParticipantsAction: Equatable {
    case leaveChatSuccess

    static func == (lhs: ParticipantsAction, rhs: ParticipantsAction) -> Bool {
        switch (lhs, rhs) {
        case (.leaveChatSuccess, .leaveChatSuccess):
            return true
        default:
            return false
        }
    }
}
