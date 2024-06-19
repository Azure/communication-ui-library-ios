//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
// swiftlint:disable type_body_length
class CallingViewModel: ObservableObject {
    @Published var isParticipantGridDisplayed: Bool
    @Published var isVideoGridViewAccessibilityAvailable = false
    @Published var appState: AppStatus = .foreground
    @Published var isInPip = false
    @Published var currentBottomToastDiagnostic: BottomToastDiagnosticViewModel?
    @Published var allowLocalCameraPreview = false
    @Published var captionsStarted = false

    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let logger: Logger
    private let store: Store<AppState, Action>
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let callType: CompositeCallType

    private var cancellables = Set<AnyCancellable>()
    private var callHasConnected = false
    private var callClientRequested = false
    private var leaveCallConfirmationMode: LeaveCallConfirmationMode?

    let localVideoViewModel: LocalVideoViewModel
    let participantGridsViewModel: ParticipantGridViewModel
    let bannerViewModel: BannerViewModel
    let lobbyOverlayViewModel: LobbyOverlayViewModel
    let loadingOverlayViewModel: LoadingOverlayViewModel
    let leaveCallConfirmationViewModel: LeaveCallConfirmationViewModel
    var onHoldOverlayViewModel: OnHoldOverlayViewModel!
    let isRightToLeft: Bool

    var controlBarViewModel: ControlBarViewModel!
    var infoHeaderViewModel: InfoHeaderViewModel!
    var lobbyWaitingHeaderViewModel: LobbyWaitingHeaderViewModel!
    var lobbyActionErrorViewModel: LobbyErrorHeaderViewModel!
    var errorInfoViewModel: ErrorInfoViewModel!
    var callDiagnosticsViewModel: CallDiagnosticsViewModel!
    var supportFormViewModel: SupportFormViewModel!
    var captionsLanguageListViewModel: CaptionsLanguageListViewModel!
    var captionsListViewModel: CaptionsListViewModel!
    var moreCallOptionsListViewModel: MoreCallOptionsListViewModel!
    var audioDeviceListViewModel: AudioDevicesListViewModel!

    // swiftlint:disable function_body_length
    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         store: Store<AppState, Action>,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         isIpadInterface: Bool,
         allowLocalCameraPreview: Bool,
         leaveCallConfirmationMode: LeaveCallConfirmationMode,
         callType: CompositeCallType
    ) {
        self.logger = logger
        self.store = store
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.isRightToLeft = localizationProvider.isRightToLeft
        self.accessibilityProvider = accessibilityProvider
        self.allowLocalCameraPreview = allowLocalCameraPreview
        self.leaveCallConfirmationMode = leaveCallConfirmationMode
        self.callType = callType
        let actionDispatch: ActionDispatch = store.dispatch

        audioDeviceListViewModel = compositeViewModelFactory.makeAudioDevicesListViewModel(
                dispatchAction: actionDispatch,
                localUserState: store.state.localUserState)

        captionsLanguageListViewModel = compositeViewModelFactory.makeCaptionsLanguageListViewModel(
            dispatchAction: actionDispatch,
            state: store.state
        )
        supportFormViewModel = compositeViewModelFactory.makeSupportFormViewModel()

        localVideoViewModel = compositeViewModelFactory.makeLocalVideoViewModel(dispatchAction: actionDispatch)
        participantGridsViewModel = compositeViewModelFactory.makeParticipantGridsViewModel(isIpadInterface:
                                                                                                isIpadInterface)
        bannerViewModel = compositeViewModelFactory.makeBannerViewModel()
        lobbyOverlayViewModel = compositeViewModelFactory.makeLobbyOverlayViewModel()
        loadingOverlayViewModel = compositeViewModelFactory.makeLoadingOverlayViewModel()
        infoHeaderViewModel = compositeViewModelFactory
            .makeInfoHeaderViewModel(dispatchAction: actionDispatch,
                                     localUserState: store.state.localUserState)
        lobbyWaitingHeaderViewModel = compositeViewModelFactory
            .makeLobbyWaitingHeaderViewModel(localUserState: store.state.localUserState,
            dispatchAction: actionDispatch)
        lobbyActionErrorViewModel = compositeViewModelFactory
            .makeLobbyActionErrorViewModel(localUserState: store.state.localUserState,
            dispatchAction: actionDispatch)

        let isCallConnected = store.state.callingState.status == .connected
        let callingStatus = store.state.callingState.status
        let isOutgoingCall = CallingViewModel.isOutgoingCallDialingInProgress(callType: callType,
                                                                              callingStatus: callingStatus)
        let isRemoteHold = store.state.callingState.status == .remoteHold

        isParticipantGridDisplayed = (isCallConnected || isOutgoingCall || isRemoteHold) &&
            CallingViewModel.hasRemoteParticipants(store.state.remoteParticipantsState.participantInfoList)

        leaveCallConfirmationViewModel = compositeViewModelFactory.makeLeaveCallConfirmationViewModel(
            endCall: {
                store.dispatch(action: .callingAction(.callEndRequested))
            }, dismissConfirmation: {
                store.dispatch(action: .hideEndCallConfirmation)
            }
        )

        controlBarViewModel = compositeViewModelFactory
            .makeControlBarViewModel(dispatchAction: actionDispatch, onEndCallTapped: { [weak self] in
                guard let self = self else {
                    return
                }
                if leaveCallConfirmationMode == .alwaysEnabled {
                    store.dispatch(action: .showEndCallConfirmation)
                } else {
                    self.endCall()
                }

            }, localUserState: store.state.localUserState,
            leaveCallConfirmationMode: leaveCallConfirmationMode)

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
        callDiagnosticsViewModel = compositeViewModelFactory
            .makeCallDiagnosticsViewModel(dispatchAction: store.dispatch)

        callDiagnosticsViewModel.$currentBottomToastDiagnostic
                    .assign(to: &$currentBottomToastDiagnostic)

        moreCallOptionsListViewModel = compositeViewModelFactory.makeMoreCallOptionsListViewModel(
            isDisplayed: store.state.navigationState.moreOptionsVisible,
            showSharingViewAction: {
                store.dispatch(action: .showSupportShare)
            },
            showSupportFormAction: {
                store.dispatch(action: .showSupportForm)
            },
            showCaptionsViewAction: {
                store.dispatch(action: .showCaptionsListView)
            }
        )

        captionsListViewModel = compositeViewModelFactory.makeCaptionsListViewModel(
            state: store.state,
            showSpokenLanguage: {
                store.dispatch(action: .showSpokenLanguageView)
            },
            showCaptionsLanguage: {
                store.dispatch(action: .showCaptionsLanguageView)
            },
            isDisplayed: store.state.navigationState.captionsViewVisible)
    }
    // swiftlint:enable function_body_length

    func endCall() {
        store.dispatch(action: .callingAction(.callEndRequested))
    }

    func resumeOnHold() {
        store.dispatch(action: .callingAction(.resumeRequested))
    }

    func dismissConfirmLeaveDrawerList() {
        store.dispatch(action: .hideEndCallConfirmation)
    }

    func dismissMoreCallOptionsDrawerList() {
        store.dispatch(action: .hideMoreOptions)
    }

    func dismissAudioDevicesDrawer() {
        store.dispatch(action: .hideAudioSelection)
    }

    func dismissCaptionLanguageDrawer() {
        store.dispatch(action: .hideCaptionsLanguageView)
    }

    func dismissSpokenLanguageDrawer() {
        store.dispatch(action: .hideCaptionsLanguageView)
    }

    func dismissCaptionsListDrawer() {
        store.dispatch(action: .hideCaptionsListView)
    }
    func receive(_ state: AppState) {
        if appState != state.lifeCycleState.currentStatus {
            appState = state.lifeCycleState.currentStatus
        }

        guard state.lifeCycleState.currentStatus == .foreground
                || state.visibilityState.currentStatus != .visible else {
            return
        }

        audioDeviceListViewModel.update(
            audioDeviceStatus: state.localUserState.audioState.device,
            navigationState: state.navigationState,
            visibilityState: state.visibilityState)

        leaveCallConfirmationViewModel.update(state: state)
        supportFormViewModel.update(state: state)
        captionsListViewModel.update(state: state)
        captionsLanguageListViewModel.update(state: state)
        controlBarViewModel.update(localUserState: state.localUserState,
                                   permissionState: state.permissionState,
                                   callingState: state.callingState,
                                   visibilityState: state.visibilityState,
                                   navigationState: state.navigationState)
        infoHeaderViewModel.update(localUserState: state.localUserState,
                                   remoteParticipantsState: state.remoteParticipantsState,
                                   callingState: state.callingState,
                                   visibilityState: state.visibilityState)
        localVideoViewModel.update(localUserState: state.localUserState,
                                   visibilityState: state.visibilityState)
        lobbyWaitingHeaderViewModel.update(localUserState: state.localUserState,
                                           remoteParticipantsState: state.remoteParticipantsState,
                                           callingState: state.callingState,
                                           visibilityState: state.visibilityState)
        lobbyActionErrorViewModel.update(localUserState: state.localUserState,
                                         remoteParticipantsState: state.remoteParticipantsState,
                                         callingState: state.callingState)
        participantGridsViewModel.update(callingState: state.callingState,
                                         remoteParticipantsState: state.remoteParticipantsState,
                                         visibilityState: state.visibilityState, lifeCycleState: state.lifeCycleState)
        bannerViewModel.update(callingState: state.callingState)
        lobbyOverlayViewModel.update(callingStatus: state.callingState.status)
        onHoldOverlayViewModel.update(callingStatus: state.callingState.status,
                                      audioSessionStatus: state.audioSessionState.status)

        moreCallOptionsListViewModel.update(navigationState: state.navigationState,
                                            visibilityState: state.visibilityState)
        let newIsCallConnected = state.callingState.status == .connected
        let isOutgoingCall = CallingViewModel.isOutgoingCallDialingInProgress(callType: callType,
                                                                              callingStatus: state.callingState.status)
        let isRemoteHold = store.state.callingState.status == .remoteHold
        let shouldParticipantGridDisplayed = (newIsCallConnected || isOutgoingCall || isRemoteHold) &&
            CallingViewModel.hasRemoteParticipants(state.remoteParticipantsState.participantInfoList)
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
        captionsStarted = state.captionsState.isStarted ?? false
        callDiagnosticsViewModel.update(diagnosticsState: state.diagnosticsState)
    }

    private static func hasRemoteParticipants(_ participants: [ParticipantInfoModel]) -> Bool {
        return participants.filter({ participant in
            participant.status != .inLobby && participant.status != .disconnected
        }).count > 0
    }

    private func updateIsLocalCameraOn(with state: AppState) {
        let isLocalCameraOn = state.localUserState.cameraState.operation == .on
        let displayName = state.localUserState.displayName ?? ""
        let isLocalUserInfoNotEmpty = isLocalCameraOn || !displayName.isEmpty
        isVideoGridViewAccessibilityAvailable = !lobbyOverlayViewModel.isDisplayed
        && !onHoldOverlayViewModel.isDisplayed
        && (isLocalUserInfoNotEmpty || isParticipantGridDisplayed)
    }

    private static func isOutgoingCallDialingInProgress(callType: CompositeCallType,
                                                        callingStatus: CallingStatus?) -> Bool {
        let isOutgoingCall = (callType == .oneToNOutgoing && (callingStatus == nil
                                                              || callingStatus == .connecting
                                                              || callingStatus == .ringing))
        return isOutgoingCall
    }
}
// swiftlint:enable type_body_length
