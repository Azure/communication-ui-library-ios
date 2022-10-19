//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageViewModel: ObservableObject, Hashable {
    let message: ChatMessageInfoModel
    let showDateHeader: Bool
    let isConsecutive: Bool

    init(message: ChatMessageInfoModel, showDateHeader: Bool, isConsecutive: Bool) {
        self.message = message
        self.showDateHeader = showDateHeader
        self.isConsecutive = isConsecutive
    }

    var dateHeaderLabel: String {
        let numberOfDaysSinceToday = message.createdOn.value.days(from: Date())
        if numberOfDaysSinceToday == 0 {
            return "Today" // Localization
        } else if numberOfDaysSinceToday == 1 {
            return "Yesterday" // Locatization
        } else {
            let format = DateFormatter()
            format.dateFormat = "MM-dd"
            let formattedDate = format.string(from: message.createdOn.value)
            return formattedDate
        }
        // Handle dates older than a year?
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(message.id)
    }

    static func == (lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
        lhs.message.id == rhs.message.id
    }
}

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

class SystemMessageViewModel: MessageViewModel {

}

extension Date {
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
}
