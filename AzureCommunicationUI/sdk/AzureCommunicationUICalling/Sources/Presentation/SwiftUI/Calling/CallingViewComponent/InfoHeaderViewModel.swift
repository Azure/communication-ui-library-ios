//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import SwiftUI

class InfoHeaderViewModel: ObservableObject {
    @Published var accessibilityLabelTitle: String
    @Published var isInfoHeaderDisplayed = true
    @Published var isVoiceOverEnabled = false
    @Published var accessibilityLabelSubtitle: String
    @Published var title = ""
    @Published var subtitle = ""
    private let logger: Logger
    private let dispatch: ActionDispatch
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private var infoHeaderDismissTimer: Timer?
    private var participantsCount: Int = 0
    private var callingStatus: CallingStatus = .none
    private let enableSystemPipWhenMultitasking: Bool
    /* <TIMER_TITLE_FEATURE> */
    private let callScreenHeaderOptions: CallScreenHeaderOptions?
     /* </TIMER_TITLE_FEATURE> */
    let enableMultitasking: Bool
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
         enableSystemPipWhenMultitasking: Bool /* <TIMER_TITLE_FEATURE> */ ,
         callScreenHeaderOptions: CallScreenHeaderOptions? /* </TIMER_TITLE_FEATURE> */ ) {
        let infoLabel = localizationProvider.getLocalizedString(.callWith0Person)
        self.callScreenHeaderOptions = callScreenHeaderOptions
        /* <TIMER_TITLE_FEATURE> */
        self.title = callScreenHeaderOptions?.title ?? infoLabel
        self.subtitle = callScreenHeaderOptions?.subtitle ?? ""
        self.accessibilityLabelTitle = callScreenHeaderOptions?.title ?? infoLabel
        self.accessibilityLabelSubtitle = callScreenHeaderOptions?.subtitle ?? ""
         /* <|TIMER_TITLE_FEATURE>
        self.title = infoLabel
        self.subtitle = ""
        self.accessibilityLabelTitle = infoLabel
        self.accessibilityLabelSubtitle = ""
        </TIMER_TITLE_FEATURE> */
        self.dispatch = dispatchAction
        self.logger = logger
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        self.enableMultitasking = enableMultitasking
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
    }
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        if interval >= 3600 {
            // If the interval is 1 hour or more, show hours, minutes, and seconds
            formatter.allowedUnits = [.hour, .minute, .second]
        } else if interval >= 60 {
            // If the interval is 1 minute or more, show minutes and seconds
            formatter.allowedUnits = [.minute, .second]
        } else {
            // If the interval is less than 1 minute, show seconds only
            formatter.allowedUnits = [.second]
        }
        return formatter.string(from: interval) ?? "00:00:00"
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
        title = self.callScreenHeaderOptions?.title ?? content
        accessibilityLabelTitle = self.callScreenHeaderOptions?.title ?? content
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
