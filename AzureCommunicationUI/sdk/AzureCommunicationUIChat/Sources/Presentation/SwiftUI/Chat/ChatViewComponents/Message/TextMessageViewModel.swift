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
    let messageSendStatusIconType: MessageSendStatus?

    init(message: ChatMessageInfoModel,
         showDateHeader: Bool,
         showUsername: Bool,
         showTime: Bool,
         isConsecutive: Bool,
         showMessageSendStatusIcon: Bool,
         messageSendStatusIconType: MessageSendStatus? = nil) {
        self.showUsername = showUsername
        self.showTime = showTime
        self.isLocalUser = message.isLocalUser
        self.showMessageSendStatusIcon = showMessageSendStatusIcon
        self.messageSendStatusIconType = messageSendStatusIconType

        super.init(message: message, showDateHeader: showDateHeader, isConsecutive: isConsecutive)
    }

    var timestamp: String {
        let createdOn = message.createdOn.value
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "a.m." // Localization?
        dateFormatter.pmSymbol = "p.m." // Localization?

        return dateFormatter.string(from: createdOn)
    }

    func getMessageSendStatusIconName() -> CompositeIcon? {
        guard showMessageSendStatusIcon == true, let messageSendStatusIconType = messageSendStatusIconType else {
            return nil
        }
        // Other cases will be handled in another PR
        switch messageSendStatusIconType {
        case .delivering:
            return nil
        case .sent:
            return nil
        case .seen:
            return .readReceipt
        case .failed:
            return nil
        }
    }

    func getContentString() -> String {
        return message.content ?? "Text not available"
    }
}
