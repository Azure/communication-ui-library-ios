//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageViewModel: ObservableObject, Hashable {
    private let id: String = ""

    let message: ChatMessageInfoModel

    init(message: ChatMessageInfoModel) {
        self.message = message
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
        true
    }
}

class TextMessageViewModel: MessageViewModel {

    init(message: ChatMessageInfoModel, showUsername: Bool, showTime: Bool, showDateHeader: Bool, isLocalUser: Bool) {
        self.showUsername = showUsername
        self.showTime = showTime
        self.showDateHeader = showDateHeader
        self.isLocalUser = isLocalUser

        super.init(message: message)
    }

    let showUsername: Bool
    let showTime: Bool
    let showDateHeader: Bool
    let isLocalUser: Bool
}

class SystemMessageViewModel: MessageViewModel {

}
