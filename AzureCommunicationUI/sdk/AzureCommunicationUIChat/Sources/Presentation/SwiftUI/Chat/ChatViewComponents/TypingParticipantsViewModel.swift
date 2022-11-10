//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCommon

class TypingParticipantsViewModel: ObservableObject {
    private let logger: Logger
    private let localizationProvider: LocalizationProviderProtocol

    private var participantsLastUpdatedTimestamp = Date()
    private var typingIndicatorLastUpdatedTimestamp = Date()
    var participants: [ParticipantInfoModel] = []
    var avatarGroup = TypingParticipantAvatarGroup()
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
        guard !participantsState.participants.isEmpty,
        !participantsState.typingParticipants.isEmpty else {
            participants = []
            avatarGroup.setAvatars(to: participants)
            hideTypingIndicator()
            return
        }
        participants = participantsState.typingParticipants
            .compactMap { model in
                participantsState.participants[model.id]
            }
            .sorted(by: { $0.displayName < $1.displayName })
        displayLabel()
    }

    private func displayLabel() {
        guard !participants.isEmpty,
              let label = getLocalizedTypingIndicatorText(participants: participants) else {
            return
        }
        shouldShowIndicator = true
        typingIndicatorLabel = label
    }

    private func hideTypingIndicator() {
        shouldShowIndicator = false
        typingIndicatorLabel = nil
    }

    private func getLocalizedTypingIndicatorText(participants: [ParticipantInfoModel]) -> String? {
        var participantList = participants
        let participantCount = TypingParticipantCount(rawValue: participants.count) ?? .mutipleTyping
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
                                                           participantList.count)
        default:
            return nil
        }
    }
}
