//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageViewModel: ObservableObject, Hashable {
    private let id: String = ""

    @Published message: ChatMessageInfoModel
    let showUsername: Bool
    let showTime: Bool
    let showDateHeader: Bool
    let isLocalUser: Bool

    init(message: ChatMessageInfoModel, showUsername: Bool, showTime: Bool, showDateHeader: Bool, isLocalUser: Bool) {
        self.message = message
        self.showUsername = showUsername
        self.showTime = showTime
        self.showDateHeader = showDateHeader
        self.isLocalUser = isLocalUser
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
        true
    }
}
