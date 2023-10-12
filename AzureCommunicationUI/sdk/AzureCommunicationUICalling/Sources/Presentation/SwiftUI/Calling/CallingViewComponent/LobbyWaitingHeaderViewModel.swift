//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class LobbyWaitingHeaderViewModel: ObservableObject {
    @Published var accessibilityLabel: String
    @Published var title: String
    @Published var isDisplayed: Bool = false
    @Published var isParticipantsListDisplayed: Bool = false
    @Published var isVoiceOverEnabled: Bool = false

    private let logger: Logger
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private var lobbyParticipantCount: Int = 0

    let participantsListViewModel: ParticipantsListViewModel
    var participantListButtonViewModel: PrimaryButtonViewModel!
    var dismissButtonViewModel: IconButtonViewModel!

    var isPad: Bool = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         dispatchAction: @escaping ActionDispatch) {
        self.logger = logger
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        let title = localizationProvider.getLocalizedString(.lobbyWaitingToJoin)
        self.title = title
        self.accessibilityLabel = title
        self.participantsListViewModel = compositeViewModelFactory.makeParticipantsListViewModel(
            localUserState: localUserState,
            dispatchAction: dispatchAction)
        self.participantListButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryFilled,
            buttonLabel: localizationProvider.getLocalizedString(.lobbyWaitingHeaderViewButton),
            iconName: nil,
            isDisabled: false,
            paddings: CompositeButton.Paddings(horizontal: 10, vertical: 6)) { [weak self] in
                guard let self = self else {
                    return
                }
                self.showParticipantListButtonTapped()
        }
        self.participantListButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .lobbyWaitingHeaderViewButtonAccessibilityLabel)

        self.dismissButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .dismiss,
            buttonType: .infoButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.isDisplayed = false
        }
        self.dismissButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .lobbyWaitingHeaderDismissButtonAccessibilityLabel)
    }

    func showParticipantListButtonTapped() {
        self.displayParticipantsList()
    }

    func displayParticipantsList() {
        self.isParticipantsListDisplayed = true
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState,
                callingState: CallingState,
                visibilityState: VisibilityState) {
        let canShow = canShowLobby(callingState: callingState,
                                   participantRole: localUserState.participantRole,
                                   visibilityState: visibilityState)

        let newLobbyParticipantCount = lobbyUsersCount(remoteParticipantsState)
        let isDisplayed = canShow
            && newLobbyParticipantCount > 0
            && (isDisplayed || newLobbyParticipantCount > lobbyParticipantCount)

        if self.isDisplayed != isDisplayed {
            self.isDisplayed = isDisplayed
        }

        self.lobbyParticipantCount = newLobbyParticipantCount

        participantsListViewModel.update(localUserState: localUserState,
                                         remoteParticipantsState: remoteParticipantsState)
    }

    private func lobbyUsersCount(_ remoteParticipantsState: RemoteParticipantsState) -> Int {
        return remoteParticipantsState.participantInfoList
            .filter({ participantInfoModel in
                participantInfoModel.status == .inLobby
            })
            .count
    }

    private func canShowLobby(callingState: CallingState,
                              participantRole: ParticipantRole,
                              visibilityState: VisibilityState) -> Bool {
        guard callingState.status != .inLobby,
              callingState.status != .localHold,
              visibilityState.currentStatus == .visible else {
            return false
        }

        return participantRole == .organizer
                || participantRole == .presenter
                || participantRole == .coorganizer
    }
}
