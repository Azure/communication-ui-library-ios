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

    let audioDeviceListViewModel: AudioDeviceListViewModel
    var cameraButtonViewModel: IconWithLabelButtonViewModel!
    var micButtonViewModel: IconWithLabelButtonViewModel!
    var audioDeviceButtonViewModel: IconWithLabelButtonViewModel!

    var cameraStatus: LocalUserState.CameraOperationalStatus = .off
    var micStatus: LocalUserState.AudioOperationalStatus = .off
    var localVideoStreamId: String?

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         dispatchAction: @escaping ActionDispatch,
         localUserState: LocalUserState) {
        self.logger = logger
        self.dispatch = dispatchAction

        self.audioDeviceListViewModel = compositeViewModelFactory.makeAudioDeviceListViewModel(
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
        let action: Action = self.cameraStatus == .on ?
        LocalUserAction.CameraOffTriggered() : LocalUserAction.CameraPreviewOnTriggered()
        dispatch(action)
    }

    func microphoneButtonTapped() {
        let action: Action = self.micStatus == .on ?
        LocalUserAction.MicrophonePreviewOff() : LocalUserAction.MicrophonePreviewOn()
        dispatch(action)
    }

    func selectAudioDeviceButtonTapped() {
        isAudioDeviceSelectionDisplayed = true
    }

    func isCameraDisabled() -> Bool {
        self.cameraPermission == .denied
    }

    func isAudioDisabled() -> Bool {
        self.audioPermission == .denied
    }

    func update(localUserState: LocalUserState, permissionState: PermissionState) {
        if self.cameraPermission != permissionState.cameraPermission {
            self.cameraPermission = permissionState.cameraPermission
        }
        if self.audioPermission != permissionState.audioPermission {
            self.audioPermission = permissionState.audioPermission
        }

        self.cameraStatus = localUserState.cameraState.operation
        self.cameraButtonViewModel.update(
            iconName: self.cameraStatus == .on ? .videoOn : .videoOff,
            buttonLabel: "Video is \(self.cameraStatus == .on ? "on" : "off")")
        self.cameraButtonViewModel.update(accessibilityLabel: "Turn camera \(self.cameraStatus == .on ? "off" : "on")")
        self.cameraButtonViewModel.update(isDisabled: isCameraDisabled())

        self.micStatus = localUserState.audioState.operation
        self.micButtonViewModel.update(
            iconName: self.micStatus == .on ? .micOn : .micOff,
            buttonLabel: "Mic is \(self.micStatus == .on ? "on" : "off")")
        self.micButtonViewModel.update(accessibilityLabel: self.micStatus == .on ? "Mute" : "Unmute")

        let audioDeviceStatus = localUserState.audioState.device
        self.audioDeviceButtonViewModel.update(
            iconName: audioDeviceStatus.icon(fallbackIcon: audioDeviceButtonViewModel.iconName),
            buttonLabel: audioDeviceStatus.label(fallbackLabel: audioDeviceButtonViewModel.buttonLabel))
        self.audioDeviceButtonViewModel.update(
            accessibilityValue: audioDeviceStatus.label(
                fallbackLabel: audioDeviceButtonViewModel.accessibilityValue ?? ""))

        if self.localVideoStreamId != localUserState.localVideoStreamIdentifier {
            self.localVideoStreamId = localUserState.localVideoStreamIdentifier
            let buttonTypeColor: IconWithLabelButtonViewModel.ButtonTypeColor
            = localVideoStreamId == nil ? .colorThemedWhite : .white
            cameraButtonViewModel.update(buttonTypeColor: buttonTypeColor)
            micButtonViewModel.update(buttonTypeColor: buttonTypeColor)
            audioDeviceButtonViewModel.update(buttonTypeColor: buttonTypeColor)
        }

        audioDeviceListViewModel.update(audioDeviceStatus: localUserState.audioState.device)
    }
}
