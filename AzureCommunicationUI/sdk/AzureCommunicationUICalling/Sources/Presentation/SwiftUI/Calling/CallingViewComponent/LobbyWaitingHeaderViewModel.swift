//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class LobbyWaitingHeaderViewModel: ObservableObject {
    @Published var accessibilityLabel: String
    @Published var infoLabel: String
    @Published var isDisplayed: Bool = true
    @Published var isParticipantsListDisplayed: Bool = false
    @Published var isVoiceOverEnabled: Bool = false

    private let logger: Logger
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private var callingStatus: CallingStatus = .none

    let participantsListViewModel: ParticipantsListViewModel
    var participantListButtonViewModel: PrimaryButtonViewModel!
    var dismissButtonViewModel: IconButtonViewModel!

    var isPad: Bool = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol) {
        self.logger = logger
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        let title = localizationProvider.getLocalizedString(.lobbyWaitingToJoin)
        self.infoLabel = title
        self.accessibilityLabel = title
        self.participantsListViewModel = compositeViewModelFactory.makeParticipantsListViewModel(
            localUserState: localUserState)
        self.participantListButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryFilled,
            buttonLabel: "View lobby",
            paddings: CompositeButton.Paddings(horizontal: 10, vertical: 6)) { [weak self] in
                guard let self = self else {
                    return
                }
                self.showParticipantListButtonTapped()
        }
        self.participantListButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .waitingInLobbyParticipantListAccessibilityLabel)

        self.dismissButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .dismiss,
            buttonType: .infoButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.isDisplayed = false
        }

        self.accessibilityProvider.subscribeToVoiceOverStatusDidChangeNotification(self)
        self.accessibilityProvider.subscribeToUIFocusDidUpdateNotification(self)
        updateInfoHeaderAvailability()
    }

    func showParticipantListButtonTapped() {
        self.displayParticipantsList()
    }

    func displayParticipantsList() {
        self.isParticipantsListDisplayed = true
    }

    func toggleDisplayInfoHeaderIfNeeded() {
        guard !isVoiceOverEnabled else {
            return
        }
        self.isDisplayed ? hideInfoHeader() : displayInfoHeader()
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState,
                callingState: CallingState) {
        let updatedRemoteparticipantCount = remoteParticipantsState.participantInfoList
            .filter({ participantInfoModel in
                participantInfoModel.status != .inLobby
            })
            .count
        isHoldingCall(callingState: callingState)
        let shouldDisplayInfoHeaderValue = shouldDisplay(for: callingStatus)
        let newDisplayInfoHeaderValue = shouldDisplay(for: callingState.status)
        callingStatus = callingState.status
        if isVoiceOverEnabled && newDisplayInfoHeaderValue != shouldDisplayInfoHeaderValue {
            updateInfoHeaderAvailability()
        }

        participantsListViewModel.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
    }

    private func isHoldingCall(callingState: CallingState) {
        guard callingState.status == .localHold,
              callingStatus != callingState.status else {
            return
        }
        if isDisplayed {
            isDisplayed = false
        }
        if isParticipantsListDisplayed {
            isParticipantsListDisplayed = false
        }
    }

    private func displayInfoHeader() {
        self.isDisplayed = true
    }

    @objc private func hideInfoHeader() {
        self.isDisplayed = false
    }

    private func updateInfoHeaderAvailability() {
        let shouldDisplay = shouldDisplay(for: callingStatus)
        isVoiceOverEnabled = accessibilityProvider.isVoiceOverEnabled

        if self.isVoiceOverEnabled {
            isDisplayed = shouldDisplay
        } else if shouldDisplay {
            displayInfoHeader()
        }
    }

    private func shouldDisplay(for callingStatus: CallingStatus) -> Bool {
        return callingStatus != .inLobby && callingStatus != .localHold
    }
}

extension LobbyWaitingHeaderViewModel: AccessibilityProviderNotificationsObserver {
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
