//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class SetupControlBarViewModel: ObservableObject {
    @Published var cameraPermission: AppPermission.Status = .unknown
    @Published var audioPermission: AppPermission.Status = .unknown
    @Published var isAudioDeviceSelectionDisplayed: Bool = false

    private let logger: Logger
    private let dispatch: ActionDispatch
    private var isJoinRequested: Bool = false
    private var callingStatus: CallingStatus = .none
    private var cameraStatus: LocalUserState.CameraOperationalStatus = .off
    private(set) var micStatus: LocalUserState.AudioOperationalStatus = .off
    private var localVideoStreamId: String?
    private(set) var cameraButtonViewModel: IconWithLabelButtonViewModel!
    private(set) var micButtonViewModel: IconWithLabelButtonViewModel!
    private(set) var audioDeviceButtonViewModel: IconWithLabelButtonViewModel!

    let audioDevicesListViewModel: AudioDevicesListViewModel

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         dispatchAction: @escaping ActionDispatch,
         localUserState: LocalUserState) {
        self.logger = logger
        self.dispatch = dispatchAction

        self.audioDevicesListViewModel = compositeViewModelFactory.makeAudioDevicesListViewModel(
            dispatchAction: dispatchAction,
            localUserState: localUserState)

        self.cameraButtonViewModel = compositeViewModelFactory.makeIconWithLabelButtonViewModel(
            iconName: .videoOff,
            buttonTypeColor: .colorThemedWhite,
            buttonLabel: "Video is off",
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Toggle camera button tapped")
                self.videoButtonTapped()
        }
        self.cameraButtonViewModel.accessibilityLabel = "Turn camera on"

        self.micButtonViewModel = compositeViewModelFactory.makeIconWithLabelButtonViewModel(
            iconName: .micOff,
            buttonTypeColor: .colorThemedWhite,
            buttonLabel: "Mic is off",
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Toggle microphone button tapped")
                self.microphoneButtonTapped()
        }
        self.micButtonViewModel.accessibilityLabel = "Unmute"

        self.audioDeviceButtonViewModel = compositeViewModelFactory.makeIconWithLabelButtonViewModel(
            iconName: .speakerFilled,
            buttonTypeColor: .colorThemedWhite,
            buttonLabel: "Device",
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Select audio device button tapped")
                self.selectAudioDeviceButtonTapped()
        }
        self.audioDeviceButtonViewModel.accessibilityLabel = "Audio device"
        self.audioDeviceButtonViewModel.accessibilityValue = "Speaker"
    }

    func videoButtonTapped() {
        let isPreview = callingStatus == .none
        let isCameraOn = cameraStatus == .on
        switch (isCameraOn, isPreview) {
        case (false, true):
            dispatch(LocalUserAction.CameraPreviewOnTriggered())
        case (false, false):
            dispatch(LocalUserAction.CameraOnTriggered())
        case (true, _):
            dispatch(LocalUserAction.CameraOffTriggered())
        }
    }

    func microphoneButtonTapped() {
        let isPreview = callingStatus == .none
        let isMicOn = micStatus == .on
        switch (isMicOn, isPreview) {
        case (false, true):
            dispatch(LocalUserAction.MicrophonePreviewOn())
        case (false, false):
            dispatch(LocalUserAction.MicrophoneOnTriggered())
        case (true, true):
            dispatch(LocalUserAction.MicrophonePreviewOff())
        case (true, false):
            dispatch(LocalUserAction.MicrophoneOffTriggered())
        }
    }

    func selectAudioDeviceButtonTapped() {
        isAudioDeviceSelectionDisplayed = true
    }

    func isCameraDisabled() -> Bool {
        return isJoinRequested || cameraPermission == .denied
    }

    func isAudioDisabled() -> Bool {
        return isJoinRequested || audioPermission == .denied
    }

    func isControlBarHidden() -> Bool {
        return audioPermission == .denied
    }

    func update(localUserState: LocalUserState,
                permissionState: PermissionState,
                callingState: CallingState) {
        if cameraPermission != permissionState.cameraPermission {
            cameraPermission = permissionState.cameraPermission
        }
        if audioPermission != permissionState.audioPermission {
            audioPermission = permissionState.audioPermission
        }
        callingStatus = callingState.status
        cameraStatus = localUserState.cameraState.operation
        micStatus = localUserState.audioState.operation
        updateButtonViewModel(localUserState: localUserState)

        if localVideoStreamId != localUserState.localVideoStreamIdentifier {
            localVideoStreamId = localUserState.localVideoStreamIdentifier
            updateButtonTypeColor(isLocalVideoOff: localVideoStreamId == nil)
        }

        audioDevicesListViewModel.update(audioDeviceStatus: localUserState.audioState.device)
    }

    func update(isJoinRequested: Bool) {
        self.isJoinRequested = isJoinRequested
        cameraButtonViewModel.update(isDisabled: isCameraDisabled())
        micButtonViewModel.update(isDisabled: isAudioDisabled())
        audioDeviceButtonViewModel.update(isDisabled: isJoinRequested)
    }

    private func updateButtonViewModel(localUserState: LocalUserState) {
        cameraButtonViewModel.update(
            iconName: self.cameraStatus == .on ? .videoOn : .videoOff,
            buttonLabel: "Video is \(self.cameraStatus == .on ? "on" : "off")")
        cameraButtonViewModel.update(accessibilityLabel: "Turn camera \(self.cameraStatus == .on ? "off" : "on")")
        cameraButtonViewModel.update(isDisabled: isCameraDisabled())
        micButtonViewModel.update(
            iconName: self.micStatus == .on ? .micOn : .micOff,
            buttonLabel: "Mic is \(self.micStatus == .on ? "on" : "off")")
        micButtonViewModel.update(accessibilityLabel: self.micStatus == .on ? "Mute" : "Unmute")
        micButtonViewModel.update(isDisabled: isAudioDisabled())
        let audioDeviceStatus = localUserState.audioState.device
        audioDeviceButtonViewModel.update(
            iconName: deviceIconFor(audioDeviceStatus: audioDeviceStatus),
            buttonLabel: deviceLabelFor(audioDeviceStatus: audioDeviceStatus))
        audioDeviceButtonViewModel.update(accessibilityValue: audioDeviceStatus.label)
    }

    private func updateButtonTypeColor(isLocalVideoOff: Bool) {
        let buttonTypeColor: IconWithLabelButtonViewModel.ButtonTypeColor
            = isLocalVideoOff ? .colorThemedWhite : .white
        cameraButtonViewModel.update(buttonTypeColor: buttonTypeColor)
        micButtonViewModel.update(buttonTypeColor: buttonTypeColor)
        audioDeviceButtonViewModel.update(buttonTypeColor: buttonTypeColor)
    }

    private func deviceIconFor(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus) -> CompositeIcon {
        switch audioDeviceStatus {
        case .bluetoothSelected:
            return .speakerBluetooth
        case .headphonesSelected:
            return .speakerRegular
        case .receiverSelected:
            return .speakerRegular
        case .speakerSelected:
            return .speakerFilled
        default:
            return audioDeviceButtonViewModel.iconName
        }
    }

    private func deviceLabelFor(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus) -> String {
        switch audioDeviceStatus {
        case .bluetoothSelected:
            return AudioDeviceType.bluetooth.rawValue
        case .headphonesSelected:
            return AudioDeviceType.headphones.name
        case .receiverSelected:
            return AudioDeviceType.receiver.name
        case .speakerSelected:
            return AudioDeviceType.speaker.name
        default:
            return audioDeviceButtonViewModel.buttonLabel
        }
    }
}
