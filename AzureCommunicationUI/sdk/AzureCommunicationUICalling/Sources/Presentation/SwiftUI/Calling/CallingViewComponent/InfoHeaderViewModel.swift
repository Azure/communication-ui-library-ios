//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import SwiftUI

class InfoHeaderViewModel: ObservableObject {
    @Published var accessibilityLabel: String
    @Published var infoLabel: String
    @Published var isInfoHeaderDisplayed = true
    @Published var isVoiceOverEnabled = false
    @Published var timer = ""
    private let logger: Logger
    private let dispatch: ActionDispatch
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private var infoHeaderDismissTimer: Timer?
    private var participantsCount: Int = 0
    private var callingStatus: CallingStatus = .none
    private let enableSystemPipWhenMultitasking: Bool
    private var callDurationManager: CallDurationManager
    let enableMultitasking: Bool
    let customTitle: String
    var participantListButtonViewModel: IconButtonViewModel!
    var dismissButtonViewModel: IconButtonViewModel!
    private var cancellables = Set<AnyCancellable>()

    var isPad = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         dispatchAction: @escaping ActionDispatch,
         enableMultitasking: Bool,
         enableSystemPipWhenMultitasking: Bool,
         callScreenHeaderOptions: CallCompositeCallScreenHeaderOptions) {
        let title = localizationProvider.getLocalizedString(.callWith0Person)
        self.customTitle = callScreenHeaderOptions.customHeaderMessage ?? title
        self.infoLabel = !customTitle.isEmpty ? customTitle: title
        self.dispatch = dispatchAction
        self.logger = logger
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        self.accessibilityLabel = title
        self.enableMultitasking = enableMultitasking
        self.callDurationManager = callScreenHeaderOptions.callCompositeCallDurationCustomTimer?.callTimerAPI as! CallDurationManager
        self.enableSystemPipWhenMultitasking = enableSystemPipWhenMultitasking
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

        dismissButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .leftArrow,
            buttonType: .infoButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.dismissButtonTapped()
        }
        dismissButtonViewModel.update(
            accessibilityLabel: self.localizationProvider.getLocalizedString(.dismissAccessibilityLabel))

        self.accessibilityProvider.subscribeToVoiceOverStatusDidChangeNotification(self)
        self.accessibilityProvider.subscribeToUIFocusDidUpdateNotification(self)
        updateInfoHeaderAvailability()
        self.callDurationManager.$timerTickStateFlow
            .receive(on: DispatchQueue.main)
            .assign(to: \.timer, on: self)
            .store(in: &cancellables)
    }

    func showParticipantListButtonTapped() {
        logger.debug("Show participant list button tapped")
        if isPad {
            self.infoHeaderDismissTimer?.invalidate()
        }
        self.displayParticipantsList()
    }

    func displayParticipantsList() {
        dispatch(.showParticipants)
    }

    func toggleDisplayInfoHeaderIfNeeded() {
        guard !isVoiceOverEnabled else {
            return
        }
        if self.isInfoHeaderDisplayed {
            hideInfoHeader()
        } else {
            displayWithTimer()
        }
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState,
                callingState: CallingState,
                visibilityState: VisibilityState) {
        isHoldingCall(callingState: callingState)
        let shouldDisplayInfoHeaderValue = shouldDisplayInfoHeader(for: callingStatus)
        let newDisplayInfoHeaderValue = shouldDisplayInfoHeader(for: callingState.status)
        callingStatus = callingState.status
        if isVoiceOverEnabled && newDisplayInfoHeaderValue != shouldDisplayInfoHeaderValue {
            updateInfoHeaderAvailability()
        }

        let updatedRemoteparticipantCount = getParticipantCount(remoteParticipantsState)

        if participantsCount != updatedRemoteparticipantCount {
            participantsCount = updatedRemoteparticipantCount
            updateInfoLabel()
        }

        if visibilityState.currentStatus == .pipModeEntered {
            hideInfoHeader()
        }
    }

    private func getParticipantCount(_ remoteParticipantsState: RemoteParticipantsState) -> Int {
        let remoteParticipantCountForGridView = remoteParticipantsState.participantInfoList
            .filter({ participantInfoModel in
                participantInfoModel.status != .inLobby && participantInfoModel.status != .disconnected
            })
            .count

        let filteredOutRemoteParticipantsCount =
        remoteParticipantsState.participantInfoList.count - remoteParticipantCountForGridView

        return remoteParticipantsState.totalParticipantCount - filteredOutRemoteParticipantsCount
    }

    private func isHoldingCall(callingState: CallingState) {
        guard callingState.status == .localHold,
              callingStatus != callingState.status else {
            return
        }
        if isInfoHeaderDisplayed {
            isInfoHeaderDisplayed = false
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

    private func dismissButtonTapped() {
        if self.enableSystemPipWhenMultitasking {
            dispatch(.visibilityAction(.pipModeRequested))
        } else if self.enableMultitasking {
            dispatch(.visibilityAction(.hideRequested))
        }
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
