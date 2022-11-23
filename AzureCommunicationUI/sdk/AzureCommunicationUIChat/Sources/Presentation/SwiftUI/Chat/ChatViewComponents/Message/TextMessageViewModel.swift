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
         isLocalUser: Bool,
         isConsecutive: Bool,
         showMessageSendStatusIcon: Bool,
         messageSendStatusIconType: MessageSendStatus? = nil) {
        self.showUsername = showUsername
        self.showTime = showTime
        self.isLocalUser = isLocalUser
        self.showMessageSendStatusIcon = showMessageSendStatusIcon
        self.messageSendStatusIconType = messageSendStatusIconType

        super.init(message: message, showDateHeader: showDateHeader, isConsecutive: isConsecutive)
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
        var content: String?
        if message.type == .text {
            content = message.content ?? "text not available"
        } else if message.type == .custom("RichText/Html") ||
                    message.type == .html {
            content = message.content?.replacingOccurrences(
                of: "<[^>]+>", with: "",
                options: String.CompareOptions.regularExpression)
//            return content?.stringByDecodingHTMLEntities ?? "not displable"
//            let htmlString = "Easy peasy lemon squeezy. &#127819;"
//            let fixedString = String(htmlEncodedString: htmlString) ?? "not displayable"
//            return fixedString
            let decoded = CFXMLCreateStringByUnescapingEntities(nil, content, nil) as String
            return decoded
        }
        return content ?? "Text not available"
    }
}


extension String {
    init?(htmlEncodedString: String) {
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        print("*** data \(htmlEncodedString) \(data)")
        guard let attributedString = try? NSAttributedString(
            data: data,
            options: options,
            documentAttributes: nil) else {
            return nil
        }
        self.init(attributedString.string)
    }
}
