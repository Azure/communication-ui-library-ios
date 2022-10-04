//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class TopBarViewModel: ObservableObject {
    private let localizationProvider: LocalizationProviderProtocol

    @Published var numberOfParticipantsLabel: String = ""

    init(localizationProvider: LocalizationProviderProtocol,
         participantsState: ParticipantsState) {
        self.localizationProvider = localizationProvider

        update(participantsState: participantsState)
    }

    private func updateNumberOfParticipantsLabel(numberOfParticpants: Int) {
        switch numberOfParticpants {
        case 0:
            numberOfParticipantsLabel = "Waiting for others to join"
//            numberOfParticipantsLabel = localizationProvider.getLocalizedString(.chatWith0Person)
        case 1:
            numberOfParticipantsLabel = "Chat with 1 person"
//            numberOfParticipantsLabel = localizationProvider.getLocalizedString(.chatWith1Person)
        default:
            numberOfParticipantsLabel = "Chat with \(numberOfParticpants) people"
//            numberOfParticipantsLabel = localizationProvider.getLocalizedString(.chatWithNPerson, numberOfParticpants)
        }
    }

    func update(participantsState: ParticipantsState) {
        updateNumberOfParticipantsLabel(
            numberOfParticpants: participantsState.numberOfParticipants)
    }
}
