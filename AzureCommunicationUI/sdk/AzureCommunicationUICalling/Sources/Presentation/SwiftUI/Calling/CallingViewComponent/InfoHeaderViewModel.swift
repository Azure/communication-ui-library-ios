//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class InfoHeaderViewModel: ObservableObject {
    @Published var accessibilityLabel: String
    @Published var infoLabel: String
    @Published var isInfoHeaderDisplayed: Bool = true
    @Published var isParticipantsListDisplayed: Bool = false
    @Published var isVoiceOverEnabled: Bool = false
    private let logger: Logger
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private var infoHeaderDismissTimer: Timer?
    private var participantsCount: Int = 0
    private var callingStatus: CallingStatus = .none

    let participantsListViewModel: ParticipantsListViewModel
    var participantListButtonViewModel: IconButtonViewModel!

    var isPad: Bool = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol) {
        self.logger = logger
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        let title = localizationProvider.getLocalizedString(.callWith0Person)
        self.infoLabel = title
        self.accessibilityLabel = title
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
        self.participantListButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .participantListAccessibilityLabel)

        self.accessibilityProvider.subscribeToVoiceOverStatusDidChangeNotification(self)
        self.accessibilityProvider.subscribeToUIFocusDidUpdateNotification(self)
        updateInfoHeaderAvailability()
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

    func toggleDisplayInfoHeaderIfNeeded() {
        guard !isVoiceOverEnabled else {
            return
        }
        self.isInfoHeaderDisplayed ? hideInfoHeader() : displayWithTimer()
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState,
                callingState: CallingState) {
        isHoldingCall(callingState: callingState)
        let shouldDisplayInfoHeaderValue = shouldDisplayInfoHeader(for: callingStatus)
        let newDisplayInfoHeaderValue = shouldDisplayInfoHeader(for: callingState.status)
        callingStatus = callingState.status
        if isVoiceOverEnabled && newDisplayInfoHeaderValue != shouldDisplayInfoHeaderValue {
            updateInfoHeaderAvailability()
        }
        if participantsCount != remoteParticipantsState.participantInfoList.count {
            participantsCount = remoteParticipantsState.participantInfoList.count
            updateInfoLabel()
        }
        participantsListViewModel.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
    }

    private func isHoldingCall(callingState: CallingState) {
        guard callingState.status == .localHold,
              callingStatus != callingState.status else {
            return
        }
        if isInfoHeaderDisplayed {
            isInfoHeaderDisplayed = false
        }
        if isParticipantsListDisplayed {
            isParticipantsListDisplayed = false
        }
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
        accessibilityLabel = content
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
        self.infoHeaderDismissTimer = Timer.scheduledTimer(withTimeInterval: 3.0,
                             repeats: false) { [weak self] _ in
            self?.hideInfoHeader()
        }
    }

    private func updateInfoHeaderAvailability() {
        let shouldDisplayInfoHeader = shouldDisplayInfoHeader(for: callingStatus)
        isVoiceOverEnabled = accessibilityProvider.isVoiceOverEnabled
        // invalidating timer is required for setting the next timer and when VoiceOver is enabled
        infoHeaderDismissTimer?.invalidate()
        if self.isVoiceOverEnabled {
            isInfoHeaderDisplayed = shouldDisplayInfoHeader
        } else if shouldDisplayInfoHeader {
            displayWithTimer()
        }
    }

    private func shouldDisplayInfoHeader(for callingStatus: CallingStatus) -> Bool {
        return callingStatus != .inLobby && callingStatus != .localHold
    }
}

extension InfoHeaderViewModel: AccessibilityProviderNotificationsObserver {
    func didUIFocusUpdateNotification(_ notification: NSNotification) {
        updateInfoHeaderAvailability()
    }

    func didChangeVoiceOverStatus(_ notification: NSNotification) {
        guard isVoiceOverEnabled != accessibilityProvider.isVoiceOverEnabled else {
            return
        }

        updateInfoHeaderAvailability()
    }
}
