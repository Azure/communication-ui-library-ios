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

        super.init(message: message, showDateHeader: showDateHeader, isConsecutive: isConsecutive)
    }
}
