//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class CallingViewModel: ObservableObject {
    @Published var isConfirmLeaveListDisplayed: Bool = false
    @Published var isParticipantGridDisplayed: Bool
    @Published var isVideoGridViewAccessibilityAvailable: Bool = false
    @Published var appState: AppStatus = .foreground
    @Published var isInPip: Bool = false

    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let logger: Logger
    private let store: Store<AppState, Action>
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol

    private var cancellables = Set<AnyCancellable>()
    private var callHasConnected: Bool = false
    private var callClientRequested: Bool = false

    let localVideoViewModel: LocalVideoViewModel
    let participantGridsViewModel: ParticipantGridViewModel
    let bannerViewModel: BannerViewModel
    let lobbyOverlayViewModel: LobbyOverlayViewModel
    let loadingOverlayViewModel: LoadingOverlayViewModel
    var onHoldOverlayViewModel: OnHoldOverlayViewModel!
    let isRightToLeft: Bool

    var controlBarViewModel: ControlBarViewModel!
    var infoHeaderViewModel: InfoHeaderViewModel!
    var errorInfoViewModel: ErrorInfoViewModel!

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         store: Store<AppState, Action>,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         isIpadInterface: Bool) {
        self.logger = logger
        self.store = store
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.isRightToLeft = localizationProvider.isRightToLeft
        self.accessibilityProvider = accessibilityProvider
        let actionDispatch: ActionDispatch = store.dispatch
        localVideoViewModel = compositeViewModelFactory.makeLocalVideoViewModel(dispatchAction: actionDispatch)
        participantGridsViewModel = compositeViewModelFactory.makeParticipantGridsViewModel(isIpadInterface:
                                                                                                isIpadInterface)
        bannerViewModel = compositeViewModelFactory.makeBannerViewModel()
        lobbyOverlayViewModel = compositeViewModelFactory.makeLobbyOverlayViewModel()
        loadingOverlayViewModel = compositeViewModelFactory.makeLoadingOverlayViewModel()

        infoHeaderViewModel = compositeViewModelFactory
            .makeInfoHeaderViewModel(dispatchAction: actionDispatch,
                                     localUserState: store.state.localUserState)
        let isCallConnected = store.state.callingState.status == .connected
        let hasRemoteParticipants = store.state.remoteParticipantsState.participantInfoList.count > 0
        isParticipantGridDisplayed = isCallConnected && hasRemoteParticipants
        controlBarViewModel = compositeViewModelFactory
            .makeControlBarViewModel(dispatchAction: actionDispatch, endCallConfirm: { [weak self] in
                guard let self = self else {
                    return
                }
                self.endCall()
            }, localUserState: store.state.localUserState)

        onHoldOverlayViewModel = compositeViewModelFactory.makeOnHoldOverlayViewModel(resumeAction: { [weak self] in
            guard let self = self else {
                return
            }
            self.resumeOnHold()
        })

        store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.receive(state)
            }.store(in: &cancellables)

        updateIsLocalCameraOn(with: store.state)
        errorInfoViewModel = compositeViewModelFactory.makeErrorInfoViewModel(title: "",
                                                                              subtitle: "")
    }

    func dismissConfirmLeaveDrawerList() {
        self.isConfirmLeaveListDisplayed = false
    }

    func requestCallClient() {
        store.dispatch(action: .callingAction(.setupCall))
        callClientRequested = true
    }

    func endCall() {
        store.dispatch(action: .callingAction(.callEndRequested))
        dismissConfirmLeaveDrawerList()
    }

    func resumeOnHold() {
        store.dispatch(action: .callingAction(.resumeRequested))
    }

    func receive(_ state: AppState) {
        if appState != state.lifeCycleState.currentStatus {
            appState = state.lifeCycleState.currentStatus
        }

        guard state.lifeCycleState.currentStatus == .foreground
                || state.visibilityState.currentStatus != .visible else {
            return
        }

        if state.callingState.operationStatus == .skipSetupRequested
            && state.permissionState.audioPermission == .granted
            && callClientRequested == false {
            requestCallClient()
        }

        controlBarViewModel.update(localUserState: state.localUserState,
                                   permissionState: state.permissionState,
                                   callingState: state.callingState,
                                   defaultUserState: state.defaultUserState,
                                   pipState: state.visibilityState)
        infoHeaderViewModel.update(localUserState: state.localUserState,
                                   remoteParticipantsState: state.remoteParticipantsState,
                                   callingState: state.callingState,
                                   visibilityState: state.visibilityState)
        localVideoViewModel.update(localUserState: state.localUserState, pipState: state.visibilityState)
        participantGridsViewModel.update(callingState: state.callingState,
                                         remoteParticipantsState: state.remoteParticipantsState,
                                         visibilityState: state.visibilityState, lifeCycleState: state.lifeCycleState)
        bannerViewModel.update(callingState: state.callingState)
        lobbyOverlayViewModel.update(callingStatus: state.callingState.status)
        onHoldOverlayViewModel.update(callingStatus: state.callingState.status,
                                      audioSessionStatus: state.audioSessionState.status)

        let newIsCallConnected = state.callingState.status == .connected
        let hasRemoteParticipants = state.remoteParticipantsState.participantInfoList.count > 0
        let shouldParticipantGridDisplayed = newIsCallConnected && hasRemoteParticipants
        if shouldParticipantGridDisplayed != isParticipantGridDisplayed {
            isParticipantGridDisplayed = shouldParticipantGridDisplayed
        }

        if callHasConnected != newIsCallConnected && newIsCallConnected {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                guard let self = self else {
                    return
                }
                self.accessibilityProvider.postQueuedAnnouncement(
                    self.localizationProvider.getLocalizedString(.joinedCallAccessibilityLabel))
            }
            callHasConnected = newIsCallConnected
        }

        updateIsLocalCameraOn(with: state)
        errorInfoViewModel.update(errorState: state.errorState)

        isInPip = state.visibilityState.currentStatus == .pipModeEntered
    }

    private func updateIsLocalCameraOn(with state: AppState) {
        let isLocalCameraOn = state.localUserState.cameraState.operation == .on
        let displayName = state.localUserState.displayName ?? ""
        let isLocalUserInfoNotEmpty = isLocalCameraOn || !displayName.isEmpty
        isVideoGridViewAccessibilityAvailable = !lobbyOverlayViewModel.isDisplayed
        && !onHoldOverlayViewModel.isDisplayed
        && (isLocalUserInfoNotEmpty || isParticipantGridDisplayed)
    }
}
