//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class TextMessageViewModel: MessageViewModel {
    let showUsername: Bool
    let showTime: Bool
    let isLocalUser: Bool

    init(message: ChatMessageInfoModel,
         showDateHeader: Bool,
         showUsername: Bool,
         showTime: Bool,
         isLocalUser: Bool,
         isConsecutive: Bool) {
        self.showUsername = showUsername
        self.showTime = showTime
        self.isLocalUser = isLocalUser

        print("SCROLL: Init Text viewModel for \(message.id)")

        super.init(message: message, showDateHeader: showDateHeader, isConsecutive: isConsecutive)
    }

    func getIconNameForMessageSendStatus(sendStatus: MessageSendStatus?) -> CompositeIcon? {
        guard message.isLocalUser else {
            return nil
        }

        // Other cases will be handled in another PR
        switch sendStatus {
        case .delivering:
            return nil
        case .sent:
            return nil
        case .seen:
            return .readReceipt
        case .failed:
            return nil
        case .none:
            return nil
        }
    }
}
