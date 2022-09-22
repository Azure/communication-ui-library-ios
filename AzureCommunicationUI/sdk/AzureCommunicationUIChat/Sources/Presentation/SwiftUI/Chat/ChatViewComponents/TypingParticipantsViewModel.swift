//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class TypingParticipantsViewModel: ObservableObject {
    private let logger: Logger

    private var typingIndicatorTimer: Timer?
    private var participantsLastUpdatedTimestamp = Date()
    private var typingIndicatorLastUpdatedTimestamp = Date()
    private var participants: [ParticipantInfoModel] = []

    @Published var typingParticipants: String = ""

    init(logger: Logger) {
        self.logger = logger
    }

    func update(participantsState: ParticipantsState) {
        if self.participantsLastUpdatedTimestamp < participantsState.participantsUpdatedTimestamp {
            self.participants = Array(participantsState.participantsInfoMap.values)
        }

        if participantsState.typingIndicatorUpdatedTimestamp != self.typingIndicatorLastUpdatedTimestamp {
            self.typingIndicatorLastUpdatedTimestamp =
            participantsState.typingIndicatorUpdatedTimestamp
            let currentTimestamp = Date()
            let typingParticipants: [ParticipantInfoModel] = participantsState.typingIndicatorMap
                .filter {
                    $0.value > currentTimestamp
                }
                .compactMap { userId, _ in
                    participantsState.participantsInfoMap[userId]
                }
            displayWithTimer(
                latestTypingTimestamp: participantsState.typingIndicatorMap.values.max() ?? Date(),
                participants: typingParticipants)
        }
    }

    private func displayWithTimer(latestTypingTimestamp: Date,
                                  participants: [ParticipantInfoModel]) {
        if participants.isEmpty {
            hideTypingIndicator()
        } else {
            typingParticipants = participants.compactMap { p in
                p.displayName
            }.joined(separator: ", ") +
            " \(participants.count == 1 ? "is" : "are") typing..."
            resetTimer(timeInterval: latestTypingTimestamp - Date())
        }
    }

    @objc private func hideTypingIndicator() {
        typingParticipants = ""
        typingIndicatorTimer?.invalidate()
    }

    private func resetTimer(timeInterval: TimeInterval = 8.0) {
        typingIndicatorTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                         target: self,
                                                         selector: #selector(hideTypingIndicator),
                                                         userInfo: nil,
                                                         repeats: false)
    }
}
