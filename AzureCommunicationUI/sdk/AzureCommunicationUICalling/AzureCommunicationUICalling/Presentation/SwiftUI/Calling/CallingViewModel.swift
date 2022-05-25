//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class CallingViewModel: ObservableObject {
    @Published var isLobbyOverlayDisplayed: Bool = false
    @Published var isOnHoldOverlayDisplayed: Bool = true
    @Published var isConfirmLeaveListDisplayed: Bool = false
    @Published var isParticipantGridDisplayed: Bool
    @Published var isVideoGridViewAccessibilityAvailable: Bool = false
    @Published var appState: AppStatus = .foreground

    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let logger: Logger
    private let store: Store<AppState>
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol

    private var cancellables = Set<AnyCancellable>()
    private var callHasConnected: Bool = false

    let localVideoViewModel: LocalVideoViewModel
    let participantGridsViewModel: ParticipantGridViewModel
    let bannerViewModel: BannerViewModel
    let isRightToLeft: Bool

    var controlBarViewModel: ControlBarViewModel!
    var infoHeaderViewModel: InfoHeaderViewModel!

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         store: Store<AppState>,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol) {
        let isCallConnected = store.state.callingState.status == .connected
        let hasRemoteParticipants = store.state.remoteParticipantsState.participantInfoList.count > 0
        let actionDispatch: ActionDispatch = store.dispatch

        self.compositeViewModelFactory = compositeViewModelFactory
        self.logger = logger
        self.store = store
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
        self.isRightToLeft = localizationProvider.isRightToLeft

        isParticipantGridDisplayed = isCallConnected && hasRemoteParticipants
        appState = store.state.lifeCycleState.currentStatus

        localVideoViewModel = compositeViewModelFactory.makeLocalVideoViewModel(dispatchAction: actionDispatch)
        participantGridsViewModel = compositeViewModelFactory.makeParticipantGridsViewModel()
        bannerViewModel = compositeViewModelFactory.makeBannerViewModel()
        infoHeaderViewModel = compositeViewModelFactory
            .makeInfoHeaderViewModel(localUserState: store.state.localUserState)
        controlBarViewModel = compositeViewModelFactory
            .makeControlBarViewModel(dispatchAction: actionDispatch, endCallConfirm: { [weak self] in
                guard let self = self else {
                    return
                }
                self.endCall()
            }, localUserState: store.state.localUserState)

        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)

        updateIsLocalCameraOn(with: store.state)
    }

    func getLobbyOverlayViewModel() -> LobbyOverlayViewModel {
        return compositeViewModelFactory.makeLobbyOverlayViewModel()
    }

    func getOnHoldOverlayViewModel() -> OnHoldOverlayViewModel {
        return compositeViewModelFactory.makeOnHoldOverlayViewModel(dispatchAction: store.dispatch)
    }

    func dismissConfirmLeaveDrawerList() {
        self.isConfirmLeaveListDisplayed = false
    }

    func endCall() {
        store.dispatch(action: CallingAction.CallEndRequested())
        dismissConfirmLeaveDrawerList()
    }

    func receive(_ state: AppState) {
        if appState != state.lifeCycleState.currentStatus {
            appState = state.lifeCycleState.currentStatus
        }

        guard state.lifeCycleState.currentStatus == .foreground else {
            return
        }

        controlBarViewModel.update(localUserState: state.localUserState,
                                   permissionState: state.permissionState)
        infoHeaderViewModel.update(localUserState: state.localUserState,
                                   remoteParticipantsState: state.remoteParticipantsState,
                                   callingState: state.callingState)
        localVideoViewModel.update(localUserState: state.localUserState)
        participantGridsViewModel.update(callingState: state.callingState,
                                         remoteParticipantsState: state.remoteParticipantsState)
        bannerViewModel.update(callingState: state.callingState)

        let newIsCallConnected = state.callingState.status == .connected
        let hasRemoteParticipants = state.remoteParticipantsState.participantInfoList.count > 0
        let shouldParticipantGridDisplayed = newIsCallConnected && hasRemoteParticipants
        if shouldParticipantGridDisplayed != isParticipantGridDisplayed {
            isParticipantGridDisplayed = shouldParticipantGridDisplayed
        }

        let shouldLobbyOverlayDisplayed = state.callingState.status == .inLobby
        if shouldLobbyOverlayDisplayed != isLobbyOverlayDisplayed {
            isLobbyOverlayDisplayed = shouldLobbyOverlayDisplayed
            accessibilityProvider.moveFocusToFirstElement()
        }

//        let shouldOnHoldOverlayDisplayed = state.AudioSessionState == .interuptted
//        if shouldOnHoldOverlayDisplayed != isOnHoldOverlayDisplayed {
//            isOnHoldOverlayDisplayed = shouldOnHoldOverlayDisplayed
//            accessibilityProvider.moveFocusToFirstElement()
//        }

        if callHasConnected != newIsCallConnected && newIsCallConnected {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.accessibilityProvider.postQueuedAnnouncement(
                    self.localizationProvider.getLocalizedString(.joinedCallAccessibilityLabel))
            }
            callHasConnected = newIsCallConnected
        }

        updateIsLocalCameraOn(with: state)
    }

    private func updateIsLocalCameraOn(with state: AppState) {
        let isLocalCameraOn = state.localUserState.cameraState.operation == .on
        let displayName = state.localUserState.displayName ?? ""
        let isLocalUserInfoNotEmpty = isLocalCameraOn || !displayName.isEmpty
        isVideoGridViewAccessibilityAvailable = !isLobbyOverlayDisplayed &&
        (isLocalUserInfoNotEmpty || isParticipantGridDisplayed)
    }
}
