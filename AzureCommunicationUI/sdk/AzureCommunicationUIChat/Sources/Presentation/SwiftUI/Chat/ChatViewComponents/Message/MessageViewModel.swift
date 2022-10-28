//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageViewModel: ObservableObject, Equatable, Identifiable {
    let showDateHeader: Bool
    let isConsecutive: Bool

    @Published private(set) var message: ChatMessageInfoModel

    init(message: ChatMessageInfoModel, showDateHeader: Bool, isConsecutive: Bool) {
        self.message = message
        self.showDateHeader = showDateHeader
        self.isConsecutive = isConsecutive
    }

    var dateHeaderLabel: String {
        let numberOfDaysSinceToday = message.createdOn.value.numberOfDays()
        if numberOfDaysSinceToday == 0 {
            return "Today" // Localization
        } else if numberOfDaysSinceToday == 1 {
            return "Yesterday" // Locatization
        } else if numberOfDaysSinceToday < 365 {
            let format = DateFormatter()
            format.dateFormat = "MMMM d"
            let formattedDate = format.string(from: message.createdOn.value)
            return formattedDate
        } else {
            let format = DateFormatter()
            format.dateFormat = "MMMM d, yyyy"
            let formattedDate = format.string(from: message.createdOn.value)
            return formattedDate
        }
    }

    static func == (lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
        lhs.message.id == rhs.message.id
    }
}

extension Date {
    func numberOfDays() -> Int {
        let calendar = Calendar.current

        let from = calendar.startOfDay(for: self)
        let to = calendar.startOfDay(for: Date())

        let components = calendar.dateComponents([.day], from: from, to: to)
        return components.day!
    }
}
