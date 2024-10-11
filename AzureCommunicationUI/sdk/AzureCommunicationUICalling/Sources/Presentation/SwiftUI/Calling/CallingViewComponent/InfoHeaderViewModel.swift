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
    @Published var subtitle: String? = ""
    /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
    @Published var customButton1ViewModel: IconButtonViewModel?
    @Published var customButton2ViewModel: IconButtonViewModel?
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
    private let logger: Logger
    private let dispatch: ActionDispatch
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private var participantsCount: Int = 0
    private var callingStatus: CallingStatus = .none
    private let enableSystemPipWhenMultitasking: Bool
    let enableMultitasking: Bool
    var participantListButtonViewModel: IconButtonViewModel!
    var dismissButtonViewModel: IconButtonViewModel!
    private var cancellables = Set<AnyCancellable>()
    /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
    private let controlHeaderViewData: CallScreenHeaderViewData?
    /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */

    var isPad = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         dispatchAction: @escaping ActionDispatch,
         enableMultitasking: Bool,
         enableSystemPipWhenMultitasking: Bool,
         callScreenInfoHeaderState: CallScreenInfoHeaderState
         /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
         ,
         buttonViewDataState: ButtonViewDataState,
         controlHeaderViewData: CallScreenHeaderViewData?
         /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
    ) {
        /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
        self.compositeViewModelFactory = compositeViewModelFactory
        self.controlHeaderViewData = controlHeaderViewData
        /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
        let infoLabel = localizationProvider.getLocalizedString(.callWith0Person)
        self.title = callScreenInfoHeaderState.title ?? infoLabel
        self.subtitle = callScreenInfoHeaderState.subtitle ?? ""
        self.accessibilityLabelTitle = callScreenInfoHeaderState.title ?? infoLabel
        self.accessibilityLabelSubtitle = callScreenInfoHeaderState.subtitle ?? ""
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
        /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
        updateCustomButtons(buttonViewDataState)
        /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
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
                visibilityState: VisibilityState,
                callScreenInfoHeaderState: CallScreenInfoHeaderState
                /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
                ,
                buttonViewDataState: ButtonViewDataState
                /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
    ) {
        isHoldingCall(callingState: callingState)
        let shouldDisplayInfoHeaderValue = shouldDisplayInfoHeader(for: callingStatus)
        let newDisplayInfoHeaderValue = shouldDisplayInfoHeader(for: callingState.status)
        callingStatus = callingState.status
        if isVoiceOverEnabled && newDisplayInfoHeaderValue != shouldDisplayInfoHeaderValue {
            updateInfoHeaderAvailability()
        }

        let updatedRemoteparticipantCount = getParticipantCount(remoteParticipantsState)

        if participantsCount != updatedRemoteparticipantCount
            && callScreenInfoHeaderState.title == nil {
            participantsCount = updatedRemoteparticipantCount
            updateInfoLabel()
        }

        if visibilityState.currentStatus == .pipModeEntered {
            hideInfoHeader()
        }
        if callScreenInfoHeaderState.title != nil
            && callScreenInfoHeaderState.title != self.title {
            self.title = (callScreenInfoHeaderState.title)!
            self.accessibilityLabelTitle = self.title
        }
        if callScreenInfoHeaderState.subtitle != nil
            && callScreenInfoHeaderState.subtitle != self.subtitle {
            self.subtitle = callScreenInfoHeaderState.subtitle
            self.accessibilityLabelSubtitle = self.subtitle ?? ""
        }
        /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
        updateCustomButtons(buttonViewDataState)
        /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
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
        title = content
        accessibilityLabelTitle = content
    }

    private func displayWithTimer() {
        self.isInfoHeaderDisplayed = true
    }

    @objc private func hideInfoHeader() {
        self.isInfoHeaderDisplayed = false
    }

    private func updateInfoHeaderAvailability() {
        let shouldDisplayInfoHeader = shouldDisplayInfoHeader(for: callingStatus)
        isVoiceOverEnabled = accessibilityProvider.isVoiceOverEnabled
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
    /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
    private func updateCustomButtons(_ buttonViewDataState: ButtonViewDataState) {
        self.customButton1ViewModel = createCustomButtonViewModel(
            buttonViewDataState.callScreenHeaderCustomButtonsState.first)

        if buttonViewDataState.callScreenHeaderCustomButtonsState.count >= 2 {
            self.customButton2ViewModel = createCustomButtonViewModel(
                buttonViewDataState.callScreenHeaderCustomButtonsState[1])
        }
    }
    private func createCustomButtonViewModel(_ customButton: CustomButtonState?) -> IconButtonViewModel? {
        guard let customButton else {
            return nil
        }
        var buttonViewModel = compositeViewModelFactory.makeIconButtonViewModel(icon: customButton.image,
                                                          buttonType: .infoButton,
                                                          isDisabled: !customButton.enabled,
                                                          isVisible: customButton.visible) { [weak self] in
            guard let optionsButton = self?.controlHeaderViewData?.customButtons.first(where: { optionsButton in
                optionsButton.id == customButton.id
            }) else {
                return
            }
            optionsButton.onClick(optionsButton)
        }

        buttonViewModel.accessibilityLabel = customButton.title
        return buttonViewModel
    }
    /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
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
