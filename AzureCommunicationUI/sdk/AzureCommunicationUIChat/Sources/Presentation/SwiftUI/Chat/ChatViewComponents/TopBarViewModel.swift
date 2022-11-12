//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class TopBarViewModel: ObservableObject {
    private let localizationProvider: LocalizationProviderProtocol
    private let dispatch: ActionDispatch

    var dismissButtonViewModel: IconButtonViewModel!
    var participantsUpdatedTimestamp = Date()
    @Published var numberOfParticipantsLabel: String = ""

    init(compositeViewModelFactory: CompositeViewModelFactory,
         localizationProvider: LocalizationProviderProtocol,
         dispatch: @escaping ActionDispatch,
         participantsState: ParticipantsState) {
        self.localizationProvider = localizationProvider
        self.dispatch = dispatch

        dismissButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .leftArrow,
            buttonType: .controlButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.dismissButtonTapped()
        }
//        dismissButtonViewModel.update(
//            accessibilityLabel: self.localizationProvider.getLocalizedString(.dismissAccessibilityLabel))

        update(participantsState: participantsState)
    }

    func dismissButtonTapped() {
        dispatch(.compositeExitAction)
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
        if participantsUpdatedTimestamp != participantsState.participantsUpdatedTimestamp {
            participantsUpdatedTimestamp = participantsState.participantsUpdatedTimestamp
            updateNumberOfParticipantsLabel(
                numberOfParticpants: participantsState.numberOfParticipants)
        }
    }
}
