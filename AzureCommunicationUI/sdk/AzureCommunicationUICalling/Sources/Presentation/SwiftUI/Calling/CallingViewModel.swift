//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
// swiftlint:disable type_body_length
internal class CallingViewModel: ObservableObject {
    @Published var isParticipantGridDisplayed: Bool
    @Published var isVideoGridViewAccessibilityAvailable = false
    @Published var appState: AppStatus = .foreground
    @Published var isInPip = false
    @Published var allowLocalCameraPreview = false
    @Published var captionsStarted = false

    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let store: Store<AppState, Action>
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let callType: CompositeCallType
    private let captionsOptions: CaptionsOptions
    private let callScreenOptions: CallScreenOptions

    private var cancellables = Set<AnyCancellable>()
    private var callHasConnected = false
    private var callClientRequested = false

    let localVideoViewModel: LocalVideoViewModel
    let participantGridsViewModel: ParticipantGridViewModel
    let bannerViewModel: BannerViewModel
    let lobbyOverlayViewModel: LobbyOverlayViewModel
    let loadingOverlayViewModel: LoadingOverlayViewModel
    let leaveCallConfirmationViewModel: LeaveCallConfirmationViewModel
    let participantListViewModel: ParticipantsListViewModel
    let participantActionViewModel: ParticipantMenuViewModel
    var onHoldOverlayViewModel: OnHoldOverlayViewModel!
    let isRightToLeft: Bool

    var controlBarViewModel: ControlBarViewModel!
    var infoHeaderViewModel: InfoHeaderViewModel!
    var lobbyWaitingHeaderViewModel: LobbyWaitingHeaderViewModel!
    var lobbyActionErrorViewModel: LobbyErrorHeaderViewModel!
    var errorInfoViewModel: ErrorInfoViewModel!
    var callDiagnosticsViewModel: CallDiagnosticsViewModel!
    var bottomToastViewModel: BottomToastViewModel!
    var supportFormViewModel: SupportFormViewModel!
    var captionsLanguageListViewModel: CaptionsLanguageListViewModel!
    var captionsRttListViewModel: CaptionsRttListViewModel!
    var moreCallOptionsListViewModel: MoreCallOptionsListViewModel!
    var audioDeviceListViewModel: AudioDevicesListViewModel!
    var captionsInfoViewModel: CaptionsRttInfoViewModel!
    var capabilitiesManager: CapabilitiesManager!
    var captionsErrorViewModel: CaptionsErrorViewModel!

    // swiftlint:disable function_body_length
    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         store: Store<AppState, Action>,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         isIpadInterface: Bool,
         allowLocalCameraPreview: Bool,
         callType: CompositeCallType,
         captionsOptions: CaptionsOptions,
         capabilitiesManager: CapabilitiesManager,
         callScreenOptions: CallScreenOptions,
         rendererViewManager: RendererViewManager
    ) {
        self.store = store
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.isRightToLeft = localizationProvider.isRightToLeft
        self.accessibilityProvider = accessibilityProvider
        self.allowLocalCameraPreview = allowLocalCameraPreview
        self.capabilitiesManager = capabilitiesManager
        self.callType = callType
        self.captionsOptions = captionsOptions
        self.callScreenOptions = callScreenOptions

        let actionDispatch: ActionDispatch = store.dispatch

        audioDeviceListViewModel = compositeViewModelFactory.makeAudioDevicesListViewModel(
                dispatchAction: actionDispatch,
                localUserState: store.state.localUserState)

        captionsLanguageListViewModel = compositeViewModelFactory.makeCaptionsLanguageListViewModel(
            dispatchAction: actionDispatch,
            state: store.state
        )

        captionsInfoViewModel = compositeViewModelFactory.makeCaptionsRttInfoViewModel(
            state: store.state, captionsOptions: captionsOptions)
        captionsErrorViewModel = compositeViewModelFactory.makeCaptionsErrorViewModel(dispatchAction: actionDispatch)
        supportFormViewModel = compositeViewModelFactory.makeSupportFormViewModel()

        localVideoViewModel = compositeViewModelFactory.makeLocalVideoViewModel(dispatchAction: actionDispatch)
        participantGridsViewModel = compositeViewModelFactory.makeParticipantGridsViewModel(
            isIpadInterface: isIpadInterface,
            rendererViewManager: rendererViewManager)
        bannerViewModel = compositeViewModelFactory.makeBannerViewModel(dispatchAction: store.dispatch)
        lobbyOverlayViewModel = compositeViewModelFactory.makeLobbyOverlayViewModel()
        loadingOverlayViewModel = compositeViewModelFactory.makeLoadingOverlayViewModel()
        infoHeaderViewModel = compositeViewModelFactory
            .makeInfoHeaderViewModel(dispatchAction: actionDispatch,
                                     localUserState: store.state.localUserState,
                                     callScreenInfoHeaderState: store.state.callScreenInfoHeaderState,
                                     buttonViewDataState: store.state.buttonViewDataState,
                                     controlHeaderViewData: callScreenOptions.headerViewData
            )
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
                store.dispatch(action: .hideDrawer)
            }
        )

        participantListViewModel = compositeViewModelFactory
            .makeParticipantsListViewModel(
                localUserState: store.state.localUserState,
                isDisplayed: store.state.navigationState.participantsVisible,
                dispatchAction: store.dispatch)

        participantActionViewModel = compositeViewModelFactory
            .makeParticipantMenuViewModel(
                localUserState: store.state.localUserState,
                isDisplayed: store.state.navigationState.participantActionsVisible,
                dispatchAction: store.dispatch)

        controlBarViewModel = compositeViewModelFactory
            .makeControlBarViewModel(dispatchAction: actionDispatch, onEndCallTapped: { [weak self] in
                guard let self = self else {
                    return
                }
                if callScreenOptions.controlBarOptions?.leaveCallConfirmationMode != .alwaysDisabled {
                    store.dispatch(action: .showEndCallConfirmation)
                } else {
                    self.endCall()
                }

            }, localUserState: store.state.localUserState,
            capabilitiesManager: capabilitiesManager,
            buttonViewDataState: store.state.buttonViewDataState)

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
        bottomToastViewModel = compositeViewModelFactory.makeBottomToastViewModel(
            toastNotificationState: store.state.toastNotificationState, dispatchAction: store.dispatch)
        let buttonActions = ButtonActions(
            showSharingViewAction: {
                store.dispatch(action: .showSupportShare)
            },
            showSupportFormAction: {
                store.dispatch(action: .showSupportForm)
            },
            showCaptionsViewAction: {
                store.dispatch(action: .showCaptionsRttListView)
            }
        )
        moreCallOptionsListViewModel = compositeViewModelFactory.makeMoreCallOptionsListViewModel(
            isCaptionsAvailable: true,
            buttonActions: buttonActions,
            controlBarOptions: callScreenOptions.controlBarOptions,
            buttonViewDataState: store.state.buttonViewDataState,
            dispatchAction: store.dispatch
        )
        let captionsButtonActions = ButtonActions(
            showSpokenLanguage: {
                store.dispatch(action: .showSpokenLanguageView)
            },
            showCaptionsLanguage: {
                store.dispatch(action: .showCaptionsLanguageView)
            },
            showRttView: {
                store.dispatch(action: .rttAction(.updateMaximized(isMaximized: true)))
                store.dispatch(action: .rttAction(.turnOnRtt))
                store.dispatch(action: .hideDrawer)
            }
        )
        captionsRttListViewModel = compositeViewModelFactory.makeCaptionsRttListViewModel(
            state: store.state,
            captionsOptions: captionsOptions,
            dispatchAction: store.dispatch,
            buttonActions: captionsButtonActions,
            isDisplayed: store.state.navigationState.captionsViewVisible)
    }
    // swiftlint:enable function_body_length

    func endCall() {
        store.dispatch(action: .callingAction(.callEndRequested))
    }

    func resumeOnHold() {
        store.dispatch(action: .callingAction(.resumeRequested))
    }

    func dismissDrawer() {
        store.dispatch(action: .hideDrawer)
    }

    func receive(_ state: AppState) {
        if appState != state.lifeCycleState.currentStatus {
            appState = state.lifeCycleState.currentStatus
        }

        guard state.visibilityState.currentStatus != .hidden else {
            return
        }
        participantListViewModel.update(localUserState: state.localUserState,
                                        remoteParticipantsState: state.remoteParticipantsState,
                                        isDisplayed: state.navigationState.participantsVisible)

        participantActionViewModel.update(localUserState: state.localUserState,
                                          isDisplayed: state.navigationState.participantActionsVisible,
                                          participantInfoModel: state.navigationState.selectedParticipant)
        audioDeviceListViewModel.update(
            audioDeviceStatus: state.localUserState.audioState.device,
            navigationState: state.navigationState,
            visibilityState: state.visibilityState)
        leaveCallConfirmationViewModel.update(state: state)
        supportFormViewModel.update(state: state)
        captionsRttListViewModel.update(state: state)
        captionsInfoViewModel.update(state: state)
        captionsLanguageListViewModel.update(state: state)
        captionsErrorViewModel.update(captionsState: state.captionsState, callingState: state.callingState)
        controlBarViewModel.update(localUserState: state.localUserState,
                                   permissionState: state.permissionState,
                                   callingState: state.callingState,
                                   visibilityState: state.visibilityState,
                                   navigationState: state.navigationState,
                                   buttonViewDataState: state.buttonViewDataState)
        infoHeaderViewModel.update(localUserState: state.localUserState,
                                   remoteParticipantsState: state.remoteParticipantsState,
                                   callingState: state.callingState,
                                   visibilityState: state.visibilityState,
                                   callScreenInfoHeaderState: state.callScreenInfoHeaderState
                                   ,
                                   buttonViewDataState: state.buttonViewDataState
                                   )
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
                                         captionsState: state.captionsState,
                                         rttState: state.rttState,
                                         remoteParticipantsState: state.remoteParticipantsState,
                                         visibilityState: state.visibilityState, lifeCycleState: state.lifeCycleState)
        bannerViewModel.update(callingState: state.callingState,
                               visibilityState: state.visibilityState)
        lobbyOverlayViewModel.update(callingStatus: state.callingState.status)
        onHoldOverlayViewModel.update(callingStatus: state.callingState.status,
                                      audioSessionStatus: state.audioSessionState.status)

        moreCallOptionsListViewModel.update(navigationState: state.navigationState,
                                            rttState: state.rttState,
                                            visibilityState: state.visibilityState,
                                            buttonViewDataState: state.buttonViewDataState)

        receiveExtension(state)
    }
    private func receiveExtension(_ state: AppState) {
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
        callDiagnosticsViewModel.update(diagnosticsState: state.diagnosticsState)
        bottomToastViewModel.update(toastNotificationState: state.toastNotificationState)
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
                                                              || callingStatus == .ringing
                                                              || callingStatus == .earlyMedia))
        return isOutgoingCall
    }
}
// swiftlint:enable type_body_length
