//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class CallingViewModel: ObservableObject {
    @Published var isLobbyOverlayDisplayed: Bool = false
    @Published var isConfirmLeaveOverlayDisplayed: Bool = false
    @Published var isParticipantGridDisplayed: Bool
    let isRightToLeft: Bool

    private let compositeViewModelFactory: CompositeViewModelFactory
    private let logger: Logger
    private let store: Store<AppState>
    private let localizationProvider: LocalizationProvider
    private var cancellables = Set<AnyCancellable>()

    var controlBarViewModel: ControlBarViewModel!
    var infoHeaderViewModel: InfoHeaderViewModel!
    let localVideoViewModel: LocalVideoViewModel
    let participantGridsViewModel: ParticipantGridViewModel
    let bannerViewModel: BannerViewModel

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         store: Store<AppState>,
         localizationProvider: LocalizationProvider) {
        self.logger = logger
        self.compositeViewModelFactory = compositeViewModelFactory
        self.store = store
        self.localizationProvider = localizationProvider
        self.isRightToLeft = localizationProvider.isRightToLeft
        let actionDispatch: ActionDispatch = store.dispatch
        localVideoViewModel = compositeViewModelFactory.makeLocalVideoViewModel(dispatchAction: actionDispatch)
        participantGridsViewModel = compositeViewModelFactory.makeParticipantGridsViewModel()
        bannerViewModel = compositeViewModelFactory.makeBannerViewModel()

        infoHeaderViewModel = compositeViewModelFactory
            .makeInfoHeaderViewModel(localUserState: store.state.localUserState)
        let isCallConnected = store.state.callingState.status == .connected
        let hasRemoteParticipants = store.state.remoteParticipantsState.participantInfoList.count > 0
        isParticipantGridDisplayed = isCallConnected && hasRemoteParticipants
        controlBarViewModel = compositeViewModelFactory
            .makeControlBarViewModel(dispatchAction: actionDispatch, endCallConfirm: { [weak self] in
                guard let self = self else {
                    return
                }
                self.displayConfirmLeaveOverlay()
            }, localUserState: store.state.localUserState)

        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)
    }

    func getLobbyOverlayViewModel() -> LobbyOverlayViewModel {
        return compositeViewModelFactory.makeLobbyOverlayViewModel()
    }

    // MARK: ConfirmLeaveOverlay
    func getLeaveCallButtonViewModel() -> PrimaryButtonViewModel {
        let leaveCallButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryFilled,
            buttonLabel: localizationProvider.getLocalizedString(.leaveCall),
            iconName: nil,
            isDisabled: false,
            action: { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Leave call button tapped")
                self.endCall()
            })
        return leaveCallButtonViewModel
    }

    func getCancelButtonViewModel() -> PrimaryButtonViewModel {
        let cancelButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryOutline,
            buttonLabel: localizationProvider.getLocalizedString(.cancel),
            iconName: nil,
            isDisabled: false,
            action: { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Cancel button tapped")
                self.dismissConfirmLeaveOverlay()
            })
        return cancelButtonViewModel
    }

    func displayConfirmLeaveOverlay() {
        self.isConfirmLeaveOverlayDisplayed = true
    }

    func dismissConfirmLeaveOverlay() {
        self.isConfirmLeaveOverlayDisplayed = false
    }

    func endCall() {
        store.dispatch(action: CallingAction.CallEndRequested())
        dismissConfirmLeaveOverlay()
    }

    func receive(_ state: AppState) {
        guard state.lifeCycleState.currentStatus == .foreground else {
            return
        }

        controlBarViewModel.update(localUserState: state.localUserState,
                                   permissionState: state.permissionState)
        infoHeaderViewModel.update(localUserState: state.localUserState,
                                   remoteParticipantsState: state.remoteParticipantsState)
        localVideoViewModel.update(localUserState: state.localUserState)
        participantGridsViewModel.update(remoteParticipantsState: state.remoteParticipantsState)
        bannerViewModel.update(callingState: state.callingState)
        let isCallConnected = state.callingState.status == .connected
        let hasRemoteParticipants = state.remoteParticipantsState.participantInfoList.count > 0
        let shouldParticipantGridDisplayed = isCallConnected && hasRemoteParticipants
        if shouldParticipantGridDisplayed != isParticipantGridDisplayed {
            isParticipantGridDisplayed = shouldParticipantGridDisplayed
        }

        let shouldLobbyOverlayDisplayed = state.callingState.status == .inLobby
        if shouldLobbyOverlayDisplayed != isLobbyOverlayDisplayed {
            isLobbyOverlayDisplayed = shouldLobbyOverlayDisplayed
        }
    }
}
