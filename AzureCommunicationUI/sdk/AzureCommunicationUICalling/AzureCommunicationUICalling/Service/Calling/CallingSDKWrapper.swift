//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCalling

class CallingSDKWrapper: NSObject, CallingSDKWrapperProtocol {
    let callingEventsHandler: CallingSDKEventsHandling

    private let logger: Logger
    private let callConfiguration: CallConfiguration
    private var callClient: CallClient?
    private var callAgent: CallAgent?
    private var call: Call?
    private var deviceManager: DeviceManager?
    private var localVideoStream: LocalVideoStream?

    private var newVideoDeviceAddedHandler: ((VideoDeviceInfo) -> Void)?

    init(logger: Logger,
         callingEventsHandler: CallingSDKEventsHandling,
         callConfiguration: CallConfiguration) {
        self.logger = logger
        self.callingEventsHandler = callingEventsHandler
        self.callConfiguration = callConfiguration
        super.init()
    }

    deinit {
        logger.debug("CallingSDKWrapper deallocated")
    }

    func setupCall() -> AnyPublisher<Void, Error> {
        setupCallClientAndDeviceManager().eraseToAnyPublisher()
    }

    func startCall(isCameraPreferred: Bool, isAudioPreferred: Bool) -> AnyPublisher<Void, Error> {
        logger.debug("Reset Subjects in callingEventsHandler")
        callingEventsHandler.setupProperties()
        self.logger.debug( "Starting call")
        return setupCallAgent()
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    let error = CallCompositeInternalError.callJoinFailed
                    return Fail(error: error).eraseToAnyPublisher()
                }
                return self.joinCall(isCameraPreferred: isCameraPreferred,
                                     isAudioPreferred: isAudioPreferred).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    func joinCall(isCameraPreferred: Bool, isAudioPreferred: Bool) -> Future<Void, Error> {
        Future { promise in
            self.logger.debug( "Joining call")
            let joinCallOptions = JoinCallOptions()

            if isCameraPreferred,
               let localVideoStream = self.localVideoStream {
                let localVideoStreamArray = [localVideoStream]
                let videoOptions = VideoOptions(localVideoStreams: localVideoStreamArray)
                joinCallOptions.videoOptions = videoOptions
            }

            joinCallOptions.audioOptions = AudioOptions()
            joinCallOptions.audioOptions?.muted = !isAudioPreferred

            var joinLocator: JoinMeetingLocator!
            if self.callConfiguration.compositeCallType == .groupCall {
                joinLocator = GroupCallLocator(groupId: self.callConfiguration.groupId!)
            } else {
                joinLocator = TeamsMeetingLinkLocator(meetingLink: self.callConfiguration.meetingLink!)
            }

            self.callAgent?.join(with: joinLocator, joinCallOptions: joinCallOptions) { [weak self] (call, error) in
                guard let self = self else {
                    return promise(.failure(CallCompositeInternalError.callJoinFailed))
                }

                if let error = error {
                    self.logger.error( "Join call failed with error")
                    return promise(.failure(error))
                }

                guard let call = call else {
                    self.logger.error( "Join call failed")
                    return promise(.failure(CallCompositeInternalError.callJoinFailed))
                }

                call.delegate = self.callingEventsHandler
                self.call = call
                self.setupCallRecordingAndTranscriptionFeature()

                return promise(.success(()))
            }
        }
    }

    func endCall() -> AnyPublisher<Void, Error> {
        Future { promise in
            self.call?.hangUp(options: HangUpOptions()) { (error) in
                if let error = error {
                    self.logger.error( "It was not possible to hangup the call.")
                    return promise(.failure(error))
                }
                self.logger.debug("Call ended successfully")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }

    func getRemoteParticipant(_ identifier: String) -> RemoteParticipant? {
        guard let call = call else {
            return nil
        }

        let remote = call.remoteParticipants.first(where: {
            $0.identifier.stringValue == identifier
        })

        return remote

    }

    func getLocalVideoStream(_ identifier: String) -> LocalVideoStream? {
        guard getLocalVideoStreamIdentifier() == identifier else {
            return nil
        }
        return localVideoStream
    }

    func startCallLocalVideoStream() -> AnyPublisher<String, Error> {
        return getValidLocalVideoStream()
            .flatMap { videoStream in
                self.startCallVideoStream(videoStream)
            }.eraseToAnyPublisher()
    }

    func stopLocalVideoStream() -> AnyPublisher<Void, Error> {
        Future { promise in
            guard let call = self.call,
                  let videoStream = self.localVideoStream else {
                self.logger.debug("Local video stopped successfully without call")
                promise(.success(()))
                return
            }
            call.stopVideo(stream: videoStream) { [weak self] (error) in
                if error != nil {
                    self?.logger.error( "Local video failed to stop. \(error!)")
                    promise(.failure(error!))
                    return
                }
                self?.logger.debug("Local video stopped successfully")
                promise(.success(()))
            }

        }.eraseToAnyPublisher()
    }

    func switchCamera() -> AnyPublisher<CameraDevice, Error> {
        guard let videoStream = self.localVideoStream else {
            let error = CallCompositeInternalError.cameraSwitchFailed
            self.logger.error("\(error)")
            return Fail(error: error).eraseToAnyPublisher()
        }

        let currentCamera = videoStream.source
        let flippedFacing: CameraFacing = currentCamera.cameraFacing == .front ? .back : .front

        return getVideoDeviceInfo(flippedFacing)
            .flatMap { [weak self] deviceInfo -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    let error = CallCompositeInternalError.cameraSwitchFailed
                    return Fail(error: error).eraseToAnyPublisher()
                }
                return self.change(videoStream, source: deviceInfo).eraseToAnyPublisher()
            }.map {
                flippedFacing.toCameraDevice()
            }.eraseToAnyPublisher()
    }

    func startPreviewVideoStream() -> AnyPublisher<String, Error> {
        return self.getValidLocalVideoStream()
            .map({ [weak self] _ in
                return self?.getLocalVideoStreamIdentifier() ?? ""
            }).eraseToAnyPublisher()
    }

    func muteLocalMic() -> AnyPublisher<Void, Error> {
        Future { promise in
            self.call?.mute { [weak self] (error) in
                if error != nil {
                    self?.logger.error( "ERROR: It was not possible to mute. \(error!)")
                    return promise(.failure(error!))
                }
                self?.logger.debug("Mute successful")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }

    func unmuteLocalMic() -> AnyPublisher<Void, Error> {
        Future { promise in
            self.call?.unmute { [weak self] (error) in
                if let error = error {
                    self?.logger.error( "ERROR: It was not possible to unmute. \(error)")
                    return promise(.failure(error))
                }
                self?.logger.debug("Unmute successful")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }

    func holdCall() -> AnyPublisher<Void, Error> {
        Future { promise in
            self.call?.hold { [weak self] (error) in
                if error != nil {
                    self?.logger.error( "ERROR: It was not possible to hold call. \(error!)")
                    return promise(.failure(error!))
                }
                self?.logger.debug("Hold Call successful")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }

    func resumeCall() -> AnyPublisher<Void, Error> {
        Future { promise in
            self.call?.resume { [weak self] (error) in
                if error != nil {
                    self?.logger.error( "ERROR: It was not possible to resume call. \(error!)")
                    return promise(.failure(error!))
                }
                self?.logger.debug("Resume Call successful")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }

}

extension CallingSDKWrapper {
    private func setupCallClientAndDeviceManager() -> Future<Void, Error> {
        Future { promise in
            self.callClient = self.makeCallClient()
            self.callClient!.getDeviceManager(completionHandler: { [weak self] (deviceManager, error) in
                guard let self = self else {
                    return
                }
                if let error = error {
                    self.logger.error("Failed to get device manager instance")
                    return promise(.failure(error))
                }
                self.deviceManager = deviceManager
                self.deviceManager?.delegate = self
                return promise(.success(()))
            })
        }
    }

    private func setupCallAgent() -> Future<Void, Error> {
        Future { promise in
            guard self.callAgent == nil else {
                self.logger.debug( "Reusing call agent")
                return promise(.success(()))
            }
            let options = CallAgentOptions()
            if let displayName = self.callConfiguration.displayName {
                options.displayName = displayName
            }

            self.callClient?.createCallAgent(userCredential: self.callConfiguration.credential,
                                             options: options) { [weak self] (agent, error) in
                guard let self = self else {
                    return promise(.failure(CallCompositeInternalError.callJoinFailed))
                }

                if let error = error {
                    self.logger.error( "It was not possible to create a call agent.")
                    return promise(.failure(error))
                }

                self.logger.debug("Call agent successfully created.")
                self.callAgent = agent
                return promise(.success(()))
            }
        }
    }

    private func makeCallClient() -> CallClient {
        let clientOptions = CallClientOptions()
        let appendingTag = self.callConfiguration.diagnosticConfig.tags
        let diagnostics = clientOptions.diagnostics ?? CallDiagnosticsOptions()
        diagnostics.tags.append(contentsOf: appendingTag)
        clientOptions.diagnostics = diagnostics
        return CallClient(options: clientOptions)
    }

    private func startCallVideoStream(_ videoStream: LocalVideoStream) -> Future<String, Error> {
        Future { promise in
            let localVideoStreamId = self.getLocalVideoStreamIdentifier() ?? ""
            guard let call = self.call else {
                let error = CallCompositeInternalError.cameraOnFailed
                self.logger.error( "Start call video stream failed")
                return promise(.failure(error))
            }
            call.startVideo(stream: videoStream) { error in
                if let error = error {
                    self.logger.error( "Local video failed to start. \(error)")
                    return promise(.failure(error))
                }
                self.logger.debug("Local video started successfully")
                return promise(.success(localVideoStreamId))
            }
        }
    }

    private func change(_ videoStream: LocalVideoStream, source: VideoDeviceInfo) -> Future<Void, Error> {
        Future { promise in
            DispatchQueue.main.async {
                videoStream.switchSource(camera: source) { [weak self] (error) in
                    if error != nil {
                        self?.logger.error( "Local video failed to switch camera. \(error!)")
                        promise(.failure(error!))
                        return
                    }
                    self?.logger.debug("Local video switched camera successfully")
                    promise(.success(()))
                }
            }
        }
    }

    private func setupCallRecordingAndTranscriptionFeature() {
        guard let call = call else {
            return
        }
        let recordingCallFeature = call.feature(Features.recording)
        let transcriptionCallFeature = call.feature(Features.transcription)
        self.callingEventsHandler.assign(recordingCallFeature)
        self.callingEventsHandler.assign(transcriptionCallFeature)
    }

    private func getLocalVideoStreamIdentifier() -> String? {
        guard localVideoStream != nil else {
            return nil
        }
        return "builtinCameraVideoStream"
    }
}

extension CallingSDKWrapper: DeviceManagerDelegate {
    func deviceManager(_ deviceManager: DeviceManager, didUpdateCameras args: VideoDevicesUpdatedEventArgs) {
        for newDevice in args.addedVideoDevices {
            newVideoDeviceAddedHandler?(newDevice)
        }
    }

    private func getVideoDeviceInfo(_ cameraFacing: CameraFacing) -> Future<VideoDeviceInfo, Error> {
        Future { promise in
            if let camera = self.deviceManager?.cameras.first(where: { $0.cameraFacing == cameraFacing }) {
                self.newVideoDeviceAddedHandler = nil
                return promise(.success(camera))
            }
            self.newVideoDeviceAddedHandler = { deviceInfo in
                if deviceInfo.cameraFacing == cameraFacing {
                    return promise(.success(deviceInfo))
                }
            }
        }
    }

    private func getValidLocalVideoStream() -> AnyPublisher<LocalVideoStream, Error> {
        if let localVideoStream = self.localVideoStream {
            return Future { promise in
                promise(.success(localVideoStream))
            }.eraseToAnyPublisher()
        }

        return getVideoDeviceInfo(.front)
            .map({[weak self] videoDeviceInfo in
                let videoStream = LocalVideoStream(camera: videoDeviceInfo)
                self?.localVideoStream = videoStream
                return videoStream
            }).eraseToAnyPublisher()
    }
}
