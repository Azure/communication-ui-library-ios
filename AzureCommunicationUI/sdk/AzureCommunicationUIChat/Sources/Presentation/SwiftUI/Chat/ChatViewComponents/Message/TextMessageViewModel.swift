//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class TextMessageViewModel: MessageViewModel {
    let showUsername: Bool
    let showTime: Bool
    let isLocalUser: Bool
    let showMessageSendStatusIcon: Bool

    init(message: ChatMessageInfoModel,
         showDateHeader: Bool,
         showUsername: Bool,
         showTime: Bool,
         isLocalUser: Bool,
         isConsecutive: Bool,
         showMessageSendStatusIcon: Bool) {
        self.showUsername = showUsername
        self.showTime = showTime
        self.isLocalUser = isLocalUser
        self.showMessageSendStatusIcon = showMessageSendStatusIcon

        super.init(message: message, showDateHeader: showDateHeader, isConsecutive: isConsecutive)
    }

    func getMessageSendStatusIconName() -> CompositeIcon? {
        guard showMessageSendStatusIcon == true else {
            return nil
        }
        // Other cases will be handled in another PR
        switch message.sendStatus {
        case .delivering:
            return nil
        case .sent:
            return nil
        case .seen:
            return .readReceipt
        case .failed:
            return nil
        case .none:
            return .readReceipt
        }
    }
}
