//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class InfoHeaderViewModel: ObservableObject {
    @Published var infoLabel: String
    @Published var isInfoHeaderDisplayed: Bool = true
    @Published var isParticipantsListDisplayed: Bool = false
    private let logger: Logger
    private let localizationProvider: LocalizationProvider
    private var infoHeaderDismissTimer: Timer?
    private var participantsCount: Int = 0

    let participantsListViewModel: ParticipantsListViewModel
    var participantListButtonViewModel: IconButtonViewModel!
    var isPad: Bool = false

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProvider) {
        self.logger = logger
        self.localizationProvider = localizationProvider
        self.infoLabel = localizationProvider.getLocalizedString(.callWith0Person)
        self.participantsListViewModel = compositeViewModelFactory.makeParticipantsListViewModel(
            localUserState: localUserState)
        self.participantListButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .showParticipant,
            buttonType: .infoButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.showParticipantListButtonTapped()
        }
        resetTimer()
    }

    func showParticipantListButtonTapped() {
        logger.debug("Show participant list button tapped")
        if isPad {
            self.infoHeaderDismissTimer?.invalidate()
        }
        self.displayParticipantsList()
    }

    func displayParticipantsList() {
        self.isParticipantsListDisplayed = true
    }

    func toggleDisplayInfoHeader() {
        self.isInfoHeaderDisplayed ? hideInfoHeader() : displayWithTimer()
    }

    func update(localUserState: LocalUserState, remoteParticipantsState: RemoteParticipantsState) {
        if participantsCount != remoteParticipantsState.participantInfoList.count {
            participantsCount = remoteParticipantsState.participantInfoList.count
            updateInfoLabel()
        }
        participantsListViewModel.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
    }

    private func updateInfoLabel() {
        let content: String
        switch participantsCount {
        case 0:
            content = localizationProvider.getLocalizedString(.callWith0Person)
        case 1:
            content = localizationProvider.getLocalizedString(.callWith1Person)
        default:
            content = localizationProvider.getLocalizedString(.callWithNPerson, participantsCount)
        }
        infoLabel = content
    }

    private func displayWithTimer() {
        self.isInfoHeaderDisplayed = true
        resetTimer()
    }

    @objc private func hideInfoHeader() {
        self.isInfoHeaderDisplayed = false
        self.infoHeaderDismissTimer?.invalidate()
    }

    private func resetTimer() {
        self.infoHeaderDismissTimer = Timer.scheduledTimer(timeInterval: 3.0,
                                                           target: self,
                                                           selector: #selector(hideInfoHeader),
                                                           userInfo: nil,
                                                           repeats: false)
    }

}
