//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

// swiftlint:disable file_length
protocol CallingMiddlewareHandling {
    @discardableResult
    func setupCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func startCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func endCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func holdCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func resumeCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func willTerminate(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func audioSessionInterrupted(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func requestCameraPreviewOn(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func requestCameraOn(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func requestCameraOff(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func requestCameraSwitch(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func requestMicrophoneMute(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func requestMicrophoneUnmute(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func onCameraPermissionIsSet(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func onMicPermissionIsGranted(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func admitAllLobbyParticipants(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func declineAllLobbyParticipants(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>
    @discardableResult
    func admitLobbyParticipant(state: AppState,
                               dispatch: @escaping ActionDispatch,
                               participantId: String) -> Task<Void, Never>
    @discardableResult
    func declineLobbyParticipant(state: AppState,
                                 dispatch: @escaping ActionDispatch,
                                 participantId: String) -> Task<Void, Never>
    @discardableResult
    func startCaptions(state: AppState,
                       dispatch: @escaping ActionDispatch,
                       language: String) -> Task<Void, Never>
    @discardableResult
    func stopCaptions(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never>

    @discardableResult
    func setCaptionsSpokenLanguage(state: AppState,
                                   dispatch: @escaping ActionDispatch,
                                   language: String) -> Task<Void, Never>
    @discardableResult
    func setCaptionsLanguage(state: AppState,
                             dispatch: @escaping ActionDispatch,
                             language: String) -> Task<Void, Never>
    func setCapabilities(capabilities: Set<ParticipantCapabilityType>,
                         state: AppState,
                         dispatch: @escaping ActionDispatch) -> Task<Void, Never>

    @discardableResult
    func onCapabilitiesChanged(event: CapabilitiesChangedEvent,
                               state: AppState,
                               dispatch: @escaping ActionDispatch) -> Task<Void, Never>

    @discardableResult
    func onNetworkQualityCallDiagnosticsUpdated(state: AppState,
                                                dispatch: @escaping ActionDispatch,
                                                diagnisticModel: NetworkQualityDiagnosticModel) -> Task<Void, Never>
    @discardableResult
    func onNetworkCallDiagnosticsUpdated(state: AppState,
                                         dispatch: @escaping ActionDispatch,
                                         diagnisticModel: NetworkDiagnosticModel) -> Task<Void, Never>
    @discardableResult
    func onMediaCallDiagnosticsUpdated(state: AppState,
                                       dispatch: @escaping ActionDispatch,
                                       diagnisticModel: MediaDiagnosticModel) -> Task<Void, Never>

    @discardableResult
    func dismissNotification(state: AppState,
                             dispatch: @escaping ActionDispatch) -> Task<Void, Never>

    @discardableResult
    func removeParticipant(state: AppState,
                           dispatch: @escaping ActionDispatch,
                           participantId: String) -> Task<Void, Never>
}

// swiftlint:disable type_body_length
class CallingMiddlewareHandler: CallingMiddlewareHandling {

    private let callingService: CallingServiceProtocol
    private let logger: Logger
    private let cancelBag = CancelBag()
    private let subscription = CancelBag()
    private let capabilitiesManager: CapabilitiesManager
    private let callType: CompositeCallType

    init(callingService: CallingServiceProtocol,
         logger: Logger,
         callType: CompositeCallType,
         capabilitiesManager: CapabilitiesManager) {
        self.callingService = callingService
        self.logger = logger
        self.callType = callType
        self.capabilitiesManager = capabilitiesManager
    }

    func setupCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.setupCall()
                if state.defaultUserState.cameraState == .on,
                   state.errorState.internalError == nil {
                    await requestCameraPreviewOn(state: state, dispatch: dispatch).value
                }
                if state.defaultUserState.audioState == .on {
                    dispatch(.localUserAction(.microphonePreviewOn))
                }
                if state.callingState.operationStatus == .skipSetupRequested {
                    dispatch(.callingAction(.callStartRequested))
                }
            } catch {
                handle(error: error, errorType: .callJoinFailed, dispatch: dispatch)
            }
        }
    }

    func startCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.startCall(
                    isCameraPreferred: state.localUserState.cameraState.operation == .on,
                    isAudioPreferred: state.localUserState.audioState.operation == .on
                )
                subscription(dispatch: dispatch,
                             isSkipRequested: state.callingState.operationStatus == .skipSetupRequested)
            } catch {
                handle(error: error, errorType: .callJoinFailed, dispatch: dispatch)
            }
        }
    }

    func endCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.endCall()
                dispatch(.callingAction(.callEnded))
            } catch {
                handle(error: error, errorType: .callEndFailed, dispatch: dispatch)
                dispatch(.callingAction(.requestFailed))
            }
        }
    }

    func holdCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected else {
                return
            }

            do {
                try await callingService.holdCall()
                await requestCameraPause(state: state, dispatch: dispatch).value
            } catch {
                handle(error: error, errorType: .callHoldFailed, dispatch: dispatch)
            }
        }
    }

    func resumeCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .localHold else {
                return
            }

            do {
                try await callingService.resumeCall()
                if state.localUserState.cameraState.operation == .paused {
                    await requestCameraOn(state: state, dispatch: dispatch).value
                }
            } catch {
                handle(error: error, errorType: .callResumeFailed, dispatch: dispatch)
            }
        }
    }

    func enterBackground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            await requestCameraPause(state: state, dispatch: dispatch).value
        }
    }

    func enterForeground(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.lifeCycleState.currentStatus == .background,
                  state.callingState.status == .connected,
                  state.localUserState.cameraState.operation == .paused else {
                return
            }
            await requestCameraOn(state: state, dispatch: dispatch).value
        }
    }

    func willTerminate(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected else {
                return
            }
            dispatch(.callingAction(.callEndRequested))
        }
    }

    func requestCameraPreviewOn(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            if state.permissionState.cameraPermission == .notAsked {
                dispatch(.permissionAction(.cameraPermissionRequested))
            } else if state.permissionState.cameraPermission == .denied {
                dispatch(.localUserAction(.cameraOffTriggered))
            } else {
                do {
                    let identifier = try await callingService.requestCameraPreviewOn()
                    dispatch(.localUserAction(.cameraOnSucceeded(videoStreamIdentifier: identifier)))
                } catch {
                    dispatch(.localUserAction(.cameraOnFailed(error: error)))
                }
            }
        }
    }

    func requestCameraOn(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            if state.permissionState.cameraPermission == .notAsked {
                dispatch(.permissionAction(.cameraPermissionRequested))
            } else {
                do {
                    let streamId = try await callingService.startLocalVideoStream()
                    try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                    dispatch(.localUserAction(.cameraOnSucceeded(videoStreamIdentifier: streamId)))
                } catch {
                    dispatch(.localUserAction(.cameraOnFailed(error: error)))
                }
            }
        }
    }

    func requestCameraOff(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.stopLocalVideoStream()
                dispatch(.localUserAction(.cameraOffSucceeded))
            } catch {
                dispatch(.localUserAction(.cameraOffFailed(error: error)))
            }
        }
    }

    func requestCameraPause(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected,
                  state.localUserState.cameraState.operation == .on else {
                return
            }

            do {
                try await callingService.stopLocalVideoStream()
                dispatch(.localUserAction(.cameraPausedSucceeded))
            } catch {
                dispatch(.localUserAction(.cameraPausedFailed(error: error)))
            }
        }
    }

    func requestCameraSwitch(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            let currentCamera = state.localUserState.cameraState.device
            do {
                let device = try await callingService.switchCamera()
                try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                dispatch(.localUserAction(.cameraSwitchSucceeded(cameraDevice: device)))
            } catch {
                dispatch(.localUserAction(.cameraSwitchFailed(previousCamera: currentCamera, error: error)))
            }
        }
    }

    func requestMicrophoneMute(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.muteLocalMic()
            } catch {
                dispatch(.localUserAction(.microphoneOffFailed(error: error)))
            }
        }
    }

    func requestMicrophoneUnmute(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.unmuteLocalMic()
            } catch {
                dispatch(.localUserAction(.microphoneOnFailed(error: error)))
            }
        }
    }

    func onCameraPermissionIsSet(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.permissionState.cameraPermission == .requesting else {
                return
            }

            switch state.localUserState.cameraState.transmission {
            case .local:
                if state.navigationState.status == .inCall {
                    dispatch(.localUserAction(.cameraOnTriggered))
                } else {
                    dispatch(.localUserAction(.cameraPreviewOnTriggered))
                }
            case .remote:
                dispatch(.localUserAction(.cameraOnTriggered))
            }
        }
    }

    func onMicPermissionIsGranted(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.permissionState.audioPermission == .requesting else {
                return
            }
            setupCall(state: state, dispatch: dispatch)
        }
    }

    func audioSessionInterrupted(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected else {
                return
            }

            dispatch(.callingAction(.holdRequested))
        }
    }

    func admitAllLobbyParticipants(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected else {
                return
            }

            do {
                try await callingService.admitAllLobbyParticipants()
            } catch {
                let errorCode = LobbyErrorCode.convertToLobbyErrorCode(error as NSError)
                dispatch(.remoteParticipantsAction(.lobbyError(errorCode: errorCode)))
            }
        }
    }

    func declineAllLobbyParticipants(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected else {
                return
            }
            let participantIds = state.remoteParticipantsState.participantInfoList.filter { participant in
                participant.status == .inLobby
            }.map { participant in
                participant.userIdentifier
            }

            for participantId in participantIds {
                do {
                    try await callingService.declineLobbyParticipant(participantId)
                } catch {
                    let errorCode = LobbyErrorCode.convertToLobbyErrorCode(error as NSError)
                    dispatch(.remoteParticipantsAction(.lobbyError(errorCode: errorCode)))
                }
            }
        }
    }

    func admitLobbyParticipant(state: AppState,
                               dispatch: @escaping ActionDispatch,
                               participantId: String) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected else {
                return
            }

            do {
                try await callingService.admitLobbyParticipant(participantId)
            } catch {
                let errorCode = LobbyErrorCode.convertToLobbyErrorCode(error as NSError)
                dispatch(.remoteParticipantsAction(.lobbyError(errorCode: errorCode)))
            }
        }
    }

    func declineLobbyParticipant(state: AppState,
                                 dispatch: @escaping ActionDispatch,
                                 participantId: String) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected else {
                return
            }

            do {
                try await callingService.declineLobbyParticipant(participantId)
            } catch {
                let errorCode = LobbyErrorCode.convertToLobbyErrorCode(error as NSError)
                dispatch(.remoteParticipantsAction(.lobbyError(errorCode: errorCode)))
            }
        }
    }

    func startCaptions(state: AppState, dispatch: @escaping ActionDispatch, language: String) -> Task<Void, Never> {
        Task {
            guard state.captionsState.isStarted == false else {
                return
            }
            do {
                try await callingService.startCaptions(language)
                dispatch(.captionsAction(.started))
            } catch {
                dispatch(.captionsAction(.error(errors: .captionsFailedToStart)))
            }
        }
    }

    func setCapabilities(capabilities: Set<ParticipantCapabilityType>,
                         state: AppState,
                         dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status != .disconnected else {
                return
            }

            do {
                if !capabilitiesManager.hasCapability(capabilities: capabilities,
                                                      capability: ParticipantCapabilityType.turnVideoOn) &&
                    state.localUserState.cameraState.operation != .off {
                    dispatch(.localUserAction(.cameraOffTriggered))
                }

                if !capabilitiesManager.hasCapability(capabilities: capabilities,
                                                      capability: ParticipantCapabilityType.unmuteMicrophone) &&
                    state.localUserState.audioState.operation != .off {
                    dispatch(.localUserAction(.microphoneOffTriggered))
                }
            }
        }
    }

    func stopCaptions(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.stopCaptions()
                dispatch(.captionsAction(.stopped))
            } catch {
                dispatch(.captionsAction(.error(errors: .captionsFailedToStop)))
            }
        }
    }

    func onCapabilitiesChanged(event: CapabilitiesChangedEvent,
                               state: AppState,
                               dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard state.callingState.status != .disconnected else {
                return
            }

            do {
                let capabilities = try await self.callingService.getCapabilities()
                dispatch(.localUserAction(.setCapabilities(capabilities: capabilities)))

                let anyLostCapability = event.changedCapabilities.contains(where: { capability in
                    (capability.type == .unmuteMicrophone && !capability.allowed) ||
                    (capability.type == .turnVideoOn && !capability.allowed) ||
                    (capability.type == .manageLobby && !capability.allowed) ||
                    (capability.type == .removeParticipant && !capability.allowed)
                })

                if anyLostCapability || !state.localUserState.currentCapabilitiesAreDefault {
                    var notificationType = ToastNotificationKind.someFeaturesGained

                    if anyLostCapability {
                        notificationType = ToastNotificationKind.someFeaturesLost
                    }
                    dispatch(.toastNotificationAction(.showNotification(kind: notificationType)))
                }
            } catch {
                self.logger.error("Fetch capabilities Failed with error : \(error)")
            }
        }
    }

    func setCaptionsSpokenLanguage(state: AppState, dispatch: @escaping ActionDispatch, language: String)
    -> Task<Void, Never> {
        Task {
            do {
                try await callingService.setCaptionsSpokenLanguage(language)
                dispatch(.captionsAction(.spokenLanguageChanged(language: language)))
            } catch {
                dispatch(.captionsAction(.error(errors: .captionsFailedToSetSpokenLanguage)))
            }
        }
    }

    func onNetworkQualityCallDiagnosticsUpdated(state: AppState,
                                                dispatch: @escaping ActionDispatch,
                                                diagnisticModel: NetworkQualityDiagnosticModel) -> Task<Void, Never> {
        Task {
            if diagnisticModel.value == .bad || diagnisticModel.value == .poor {
                switch diagnisticModel.diagnostic {
                case .networkReceiveQuality:
                    dispatch(.toastNotificationAction(.showNotification(kind: .networkReceiveQuality)))
                case .networkReconnectionQuality:
                    dispatch(.toastNotificationAction(.showNotification(kind: .networkReconnectionQuality)))
                case .networkSendQuality:
                    dispatch(.toastNotificationAction(.showNotification(kind: .networkSendQuality)))
                }
            } else {
                dispatch(.toastNotificationAction(.dismissNotification))
            }
        }
    }

    func setCaptionsLanguage(state: AppState, dispatch: @escaping ActionDispatch, language: String)
    -> Task<Void, Never> {
        Task {
            do {
                try await callingService.setCaptionsCaptionLanguage(language)
                dispatch(.captionsAction(.captionLanguageChanged(language: language)))
            } catch {
                dispatch(.captionsAction(.error(errors: .failedToSetCaptionLanguage)))
            }
        }
    }

    func onNetworkCallDiagnosticsUpdated(state: AppState,
                                         dispatch: @escaping ActionDispatch,
                                         diagnisticModel: NetworkDiagnosticModel) -> Task<Void, Never> {
        Task {
            if diagnisticModel.value {
                switch diagnisticModel.diagnostic {
                case .networkRelaysUnreachable:
                    dispatch(.toastNotificationAction(.showNotification(kind: .networkRelaysUnreachable)))
                case .networkUnavailable:
                    dispatch(.toastNotificationAction(.showNotification(kind: .networkUnavailable)))
                }
            }
        }
    }

    func onMediaCallDiagnosticsUpdated(state: AppState,
                                       dispatch: @escaping ActionDispatch,
                                       diagnisticModel: MediaDiagnosticModel) -> Task<Void, Never> {
        Task {
            switch diagnisticModel.diagnostic {
            case .speakingWhileMicrophoneIsMuted:
                if diagnisticModel.value {
                    dispatch(.toastNotificationAction(.showNotification(kind: .speakingWhileMicrophoneIsMuted)))
                } else {
                    dispatch(.toastNotificationAction(.dismissNotification))
                }
            case .cameraStartFailed:
                if diagnisticModel.value {
                    dispatch(.toastNotificationAction(.showNotification(kind: .cameraStartFailed)))
                }
            case .cameraStartTimedOut:
                if diagnisticModel.value {
                    dispatch(.toastNotificationAction(.showNotification(kind: .cameraStartTimedOut)))
                }
            default:
                break
            }
        }
    }

    func dismissNotification(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            guard let toastState = state.toastNotificationState.status else {
                return
            }
            switch toastState {
            case ToastNotificationKind.networkUnavailable:
                dispatch(.callDiagnosticAction(.dismissNetwork(diagnostic: .networkUnavailable)))
            case .networkRelaysUnreachable:
                dispatch(.callDiagnosticAction(.dismissNetwork(diagnostic: .networkRelaysUnreachable)))
            case .networkReceiveQuality:
                dispatch(.callDiagnosticAction(.dismissNetworkQuality(diagnostic: .networkReceiveQuality)))
            case .networkReconnectionQuality:
                dispatch(.callDiagnosticAction(.dismissNetworkQuality(diagnostic: .networkReconnectionQuality)))
            case .networkSendQuality:
                dispatch(.callDiagnosticAction(.dismissNetworkQuality(diagnostic: .networkSendQuality)))
            case .speakingWhileMicrophoneIsMuted:
                dispatch(.callDiagnosticAction(.dismissMedia(diagnostic: .speakingWhileMicrophoneIsMuted)))
            case .cameraStartFailed:
                dispatch(.callDiagnosticAction(.dismissMedia(diagnostic: .cameraStartFailed)))
            case .cameraStartTimedOut:
                dispatch(.callDiagnosticAction(.dismissMedia(diagnostic: .cameraStartTimedOut)))
            case .someFeaturesLost, .someFeaturesGained:
                break
            }
        }
    }

    func removeParticipant(state: AppState,
                           dispatch: @escaping ActionDispatch,
                           participantId: String) -> Task<Void, Never> {
        Task {
            guard state.callingState.status == .connected else {
                return
            }

            do {
                try await callingService.removeParticipant(participantId)
            } catch {
                dispatch(.remoteParticipantsAction(.removeParticipantError))
            }
        }
    }
}

extension CallingMiddlewareHandler {
    // swiftlint:disable function_body_length
    private func subscription(dispatch: @escaping ActionDispatch,
                              isSkipRequested: Bool = false) {
        logger.debug("Subscribe to calling service subjects")
        callingService.participantsInfoListSubject
            .throttle(for: 1.25, scheduler: DispatchQueue.main, latest: true)
            .sink { list in
                dispatch(.remoteParticipantsAction(.participantListUpdated(participants: list)))
            }.store(in: subscription)

        callingService.callInfoSubject
            .sink { [weak self] callInfoModel in
                guard let self = self else {
                    return
                }
                let internalError = callInfoModel.internalError
                let callingStatus = callInfoModel.status
                self.handle(callInfoModel: callInfoModel, dispatch: dispatch, callType: self.callType)
                self.logger.debug("Dispatch State Update: \(callingStatus)")

                if let internalError = internalError {
                    self.handleCallInfo(internalError: internalError,
                                        dispatch: dispatch) {
                        self.logger.debug("Subscription cancelled with Error Code: \(internalError)")
                        if isSkipRequested {
                            dispatch(.compositeExitAction)
                        }
                        self.subscription.cancel()
                    }
                    // to fix the bug that resume call won't work without Internet
                    // we exit the UI library when we receive the wrong status .remoteHold
                } else if callingStatus == .disconnected {
                    self.logger.debug("Subscription cancel happy path")
                    dispatch(.compositeExitAction)
                    self.subscription.cancel()
                }

            }.store(in: subscription)

        callingService.isRecordingActiveSubject
            .removeDuplicates()
            .sink { isRecordingActive in
                dispatch(.callingAction(.recordingStateUpdated(isRecordingActive: isRecordingActive)))
            }.store(in: subscription)

        callingService.isTranscriptionActiveSubject
            .removeDuplicates()
            .sink { isTranscriptionActive in
                dispatch(.callingAction(.transcriptionStateUpdated(isTranscriptionActive: isTranscriptionActive)))
            }.store(in: subscription)

        callingService.isLocalUserMutedSubject
            .removeDuplicates()
            .sink { isLocalUserMuted in
                dispatch(.localUserAction(.microphoneMuteStateUpdated(isMuted: isLocalUserMuted)))
            }.store(in: subscription)

        callingService.callIdSubject
            .removeDuplicates()
            .sink { callId in
                dispatch(.callingAction(.callIdUpdated(callId: callId)))
            }.store(in: subscription)

        callingService.dominantSpeakersSubject
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true)
            .sink { speakers in
                dispatch(.remoteParticipantsAction(.dominantSpeakersUpdated(speakers: speakers)))
            }.store(in: subscription)

        callingService.participantRoleSubject
            .removeDuplicates()
            .sink { participantRole in
                dispatch(.localUserAction(.participantRoleChanged(participantRole: participantRole)))
            }.store(in: subscription)

        callingService.totalParticipantCountSubject
            .removeDuplicates()
            .sink { participantCount in
                dispatch(.remoteParticipantsAction(.setTotalParticipantCount(participantCount: participantCount)))
            }.store(in: subscription)
        subscribeOnDiagnostics(dispatch: dispatch)
        subscribeCapabilitiesUpdate(dispatch: dispatch)
    }

    private func subscribeOnDiagnostics(dispatch: @escaping ActionDispatch) {

        callingService.networkDiagnosticsSubject
            .removeDuplicates()
            .sink { networkDiagnostic in
                dispatch(.callDiagnosticAction(.network(diagnostic: networkDiagnostic)))
            }.store(in: subscription)

        callingService.networkQualityDiagnosticsSubject
            .removeDuplicates()
            .sink { networkQualityDiagnostic in
                dispatch(.callDiagnosticAction(.networkQuality(diagnostic: networkQualityDiagnostic)))
            }.store(in: subscription)

        callingService.mediaDiagnosticsSubject
            .removeDuplicates()
            .sink { mediaDiagnostic in
                dispatch(.callDiagnosticAction(.media(diagnostic: mediaDiagnostic)))
            }.store(in: subscription)

        callingService.supportedSpokenLanguagesSubject
            .removeDuplicates()
            .sink { supportSpokenLanguage in
                dispatch(.captionsAction(.supportedSpokenLanguagesChanged(languages: supportSpokenLanguage)))
            }.store(in: subscription)
        callingService.supportedCaptionLanguagesSubject
            .sink { supportCaptionsLanguage in
                dispatch(.captionsAction(.supportedCaptionLanguagesChanged(languages: supportCaptionsLanguage)))
            }.store(in: subscription)
        callingService.activeSpokenLanguageSubject
            .sink { spokenLanguage in
                dispatch(.captionsAction(.spokenLanguageChanged(language: spokenLanguage)))
            }.store(in: subscription)
        callingService.activeCaptionLanguageSubject
            .sink { captionsLanguage in
                dispatch(.captionsAction(.captionLanguageChanged(language: captionsLanguage)))
            }.store(in: subscription)
        callingService.captionsTypeSubject.sink { captionsType in
            dispatch(.captionsAction(.typeChanged(type: captionsType)))
        }.store(in: subscription)
    }

    private func subscribeCapabilitiesUpdate(dispatch: @escaping ActionDispatch) {
        callingService.capabilitiesChangedSubject
            .removeDuplicates()
            .sink { event in
                dispatch(.localUserAction(.onCapabilitiesChanged(event: event)))
            }.store(in: subscription)
    }
}
// swiftlint:enable type_body_length
