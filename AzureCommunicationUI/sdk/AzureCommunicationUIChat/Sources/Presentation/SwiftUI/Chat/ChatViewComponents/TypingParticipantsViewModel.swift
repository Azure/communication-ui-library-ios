//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import AzureCommunicationCommon

class TypingParticipantsViewModel: ObservableObject {
    private let logger: Logger
    private let localizationProvider: LocalizationProviderProtocol

    private var typingIndicatorTimer: Timer?
    private var participantsLastUpdatedTimestamp = Date()
    private var typingIndicatorLastUpdatedTimestamp = Date()
    var participants: [ParticipantInfoModel] = [
        ParticipantInfoModel(identifier: CommunicationUserIdentifier("2843y8hd"), displayName: "John Peng")]

    @Published var typingParticipants: String = Constants.defaultParticipant

    private enum Constants {
        static let defaultParticipant: String = ""
        static let participantSeparator: String = ", "
        static let defaultTimeInterval: TimeInterval = 8.0
    }

    init(logger: Logger,
         localizationProvider: LocalizationProviderProtocol) {
        self.logger = logger
        self.localizationProvider = localizationProvider
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
            }.joined(separator: Constants.participantSeparator)
            typingParticipants += participants.count == 1 ?
            localizationProvider.getLocalizedString(.participantIsTyping):
            localizationProvider.getLocalizedString(.participantsAreTyping)
            resetTimer(timeInterval: Date().timeIntervalSince(latestTypingTimestamp))
        }
    }

    @objc private func hideTypingIndicator() {
        typingParticipants = Constants.defaultParticipant
        typingIndicatorTimer?.invalidate()
    }

    private func resetTimer(timeInterval: TimeInterval = Constants.defaultTimeInterval) {
        typingIndicatorTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                         target: self,
                                                         selector: #selector(hideTypingIndicator),
                                                         userInfo: nil,
                                                         repeats: false)
    }
}
