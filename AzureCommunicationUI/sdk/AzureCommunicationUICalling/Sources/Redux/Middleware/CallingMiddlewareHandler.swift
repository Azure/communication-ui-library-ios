//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit
import Combine
import Foundation
import PushKit

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
    func registerForPushNotifications() -> Task<Void, Never>
}

class CallingMiddlewareHandler: NSObject, CallingMiddlewareHandling {
    private let callingService: CallingServiceProtocol
    private let logger: Logger
    private let cancelBag = CancelBag()
    private let subscription = CancelBag()

    private let voipRegistry = PKPushRegistry(queue: .main)
    private let callKitProvider: CXProvider
    private let callController = CXCallController()
    private var cxTransaction: CXTransaction?

    init(callingService: CallingServiceProtocol, logger: Logger) {
        self.callingService = callingService
        self.logger = logger
        let cxConfiguration = CXProviderConfiguration()
        cxConfiguration.supportsVideo = true
        cxConfiguration.supportedHandleTypes = [.generic]

        self.callKitProvider = CXProvider(
            configuration: cxConfiguration
        )
        super.init()
    }

    func setupCall(state: AppState, dispatch: @escaping ActionDispatch) -> Task<Void, Never> {
        Task {
            do {
                try await callingService.setupCall()
                if state.permissionState.cameraPermission == .granted,
                   state.localUserState.cameraState.operation == .off,
                   state.errorState.internalError == nil {
                    dispatch(.localUserAction(.cameraPreviewOnTriggered))
                }
                // Setup call kit for call
                let handle = CXHandle(
                    type: .generic,
                    value: state.localUserState.displayName ?? "Unnamed User"
                )
                let transaction = CXTransaction(
                    action: CXStartCallAction(
                        call: UUID(),
                        handle: handle)
                )
                try await callController.request(transaction)
                cxTransaction = transaction
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
                subscription(dispatch: dispatch)

                let startCallAction = CXStartCallAction(
                    call: UUID(),
                    handle: CXHandle(type: .generic, value: ))
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
            guard state.callingState.status == .connected || state.callingState.status == .localHold,
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
            do {
                let device = try await callingService.switchCamera()
                try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                dispatch(.localUserAction(.cameraSwitchSucceeded(cameraDevice: device)))
            } catch {
                dispatch(.localUserAction(.cameraSwitchFailed(error: error)) )
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
                dispatch(.localUserAction(.cameraPreviewOnTriggered))
            case .remote:
                dispatch(.localUserAction(.cameraOnTriggered))
            }
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

    func registerForPushNotifications() -> Task<Void, Never> {
        return Task {
            guard voipRegistry.delegate == nil else {
                return
            }

            voipRegistry.delegate = self
            // Set the push type to VoIP, which starts the registration
            voipRegistry.desiredPushTypes = [.voIP]
        }
    }
}

extension CallingMiddlewareHandler {
    private func subscription(dispatch: @escaping ActionDispatch) {
        logger.debug("Subscribe to calling service subjects")
        callingService.participantsInfoListSubject
            .throttle(for: 1.25, scheduler: DispatchQueue.main, latest: true)
            .sink { list in
                dispatch(.callingAction(.participantListUpdated(participants: list)))
            }.store(in: subscription)

        callingService.callInfoSubject
            .sink { [weak self] callInfoModel in
                guard let self = self else {
                    return
                }
                let internalError = callInfoModel.internalError
                let callingStatus = callInfoModel.status

                self.handle(callingStatus: callingStatus, dispatch: dispatch)
                self.logger.debug("Dispatch State Update: \(callingStatus)")

                if let internalError = internalError {
                    self.handleCallInfo(internalError: internalError,
                                        dispatch: dispatch) {
                        self.logger.debug("Subscription cancelled with Error Code: \(internalError)")
                        self.subscription.cancel()
                    }
                    // to fix the bug that resume call won't work without Internet
                    // we exit the UI library when we receive the wrong status .remoteHold
                } else if callingStatus == .disconnected || callingStatus == .remoteHold {
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
    }
}

extension CallingMiddlewareHandler: CXProviderDelegate {

    /// For outgoing calls
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {

    }

    /// For incoming calls
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {

        // Implement all the logic to getting to the call screen here, and connect the call

        // Answer the call, when we have setup
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // handle the ending of the call
        // hang up, clean up and report we're done
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // handle putting the call on hold / resume
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        // handle muting / unmuting the call
    }

    func providerDidReset(_ provider: CXProvider) {
        // handle the reset
        // Stop any calls in progress, clean up.
    }
}

extension CallingMiddlewareHandler: PKPushRegistryDelegate {

    func pushRegistry(_ registry: PKPushRegistry,
                      didUpdate pushCredentials: PKPushCredentials,
                      for type: PKPushType) {
        let token = pushCredentials.token

        // Make this a redux action dispatch?
        Task {
            try await callingService.registerForPushNotifications(token: token)
        }
    }

    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        // Process the push, start up the app straight to the call screen?
        guard type == .voIP else {
            return
        }

        // Extract the call information from the push notification payload
        if let handle = payload.dictionaryPayload["handle"] as? String,
           let uuidString = payload.dictionaryPayload["callUUID"] as? String,
           let callUUID = UUID(uuidString: uuidString) {

            // Configure the call information data structures.
            let callUpdate = CXCallUpdate()
            callUpdate.remoteHandle = CXHandle(type: .generic, value: handle)

            // Report the call to CallKit, and let it display the call UI.
            callKitProvider.reportNewIncomingCall(
                with: callUUID,
                update: callUpdate
            ) { error in
                if let err = error {
                    print(err)
                }
            }
        }
    }
}
