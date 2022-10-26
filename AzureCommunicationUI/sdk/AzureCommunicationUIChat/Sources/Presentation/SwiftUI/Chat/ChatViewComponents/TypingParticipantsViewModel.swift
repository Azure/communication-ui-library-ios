//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon

class TypingParticipantsViewModel: ObservableObject {
    private let logger: Logger
    private let localizationProvider: LocalizationProviderProtocol

    private var typingIndicatorTimer: Timer?
    private var participantsLastUpdatedTimestamp = Date()
    private var typingIndicatorLastUpdatedTimestamp = Date()
    var participants: [ParticipantInfoModel] = []

    @Published var typingIndicatorLabel: String?
    var shouldShowIndicator: Bool = false

    private enum Constants {
        static let defaultTimeInterval: TimeInterval = 8.0
    }

    private enum TypingParticipantCount: Int {
        case none
        case singleTyping
        case twoTyping
        case threeTyping
        case mutipleTyping
    }

    init(logger: Logger,
         localizationProvider: LocalizationProviderProtocol) {
        self.logger = logger
        self.localizationProvider = localizationProvider
    }

    func update(participantsState: ParticipantsState) {
        if self.participantsLastUpdatedTimestamp < participantsState.participantsUpdatedTimestamp {
            self.participants = Array(participantsState.participants.values)
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
                    participantsState.participants[userId]
                }
                .sorted(by: { $0.displayName < $1.displayName })
            displayWithTimer(
                latestTypingTimestamp: participantsState.typingIndicatorMap.values.max() ?? Date(),
                participants: typingParticipants)
        }
    }

    private func displayWithTimer(latestTypingTimestamp: Date,
                                  participants: [ParticipantInfoModel]) {
        guard !participants.isEmpty,
              let label = getLocalizedTypingIndicatorText(participants: participants) else {
            return
        }
        shouldShowIndicator = true
        typingIndicatorLabel = label
        resetTimer(timeInterval: Date().timeIntervalSince(latestTypingTimestamp))
    }

    @objc private func hideTypingIndicator() {
        shouldShowIndicator = false
        typingIndicatorLabel = nil
        typingIndicatorTimer?.invalidate()
    }

    private func getLocalizedTypingIndicatorText(participants: [ParticipantInfoModel]) -> String? {
        var participantList = participants
        var participantCount = TypingParticipantCount(rawValue: participants.count) ?? .mutipleTyping
        switch participantCount {
        case .singleTyping:
            // X is typing
            return localizationProvider.getLocalizedString(.oneParticipantIsTyping,
                                                           participantList.removeFirst().displayName)
        case .twoTyping:
            // X and Y are typing
            return localizationProvider.getLocalizedString(.twoParticipantsAreTyping,
                                                           participantList.removeFirst().displayName,
                                                           participantList.removeFirst().displayName)
        case .threeTyping:
            // X, Y and 1 other are typing
            return localizationProvider.getLocalizedString(.threeParticipantsAreTyping,
                                                               participantList.removeFirst().displayName,
                                                               participantList.removeFirst().displayName)
        case .mutipleTyping:
            // X, Y and N others are typing
            return localizationProvider.getLocalizedString(.multipleParticipantsAreTyping,
                                                           participantList.removeFirst().displayName,
                                                           participantList.removeFirst().displayName,
                                                           participants.count)
        default:
            return nil
        }
    }

    private func resetTimer(timeInterval: TimeInterval = Constants.defaultTimeInterval) {
        typingIndicatorTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                         target: self,
                                                         selector: #selector(hideTypingIndicator),
                                                         userInfo: nil,
                                                         repeats: false)
    }
}
