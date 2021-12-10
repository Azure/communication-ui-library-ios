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
    let audioDeviceListViewModel: AudioDeviceListViewModel
    var cameraButtonViewModel: IconWithLabelButtonViewModel!
    var micButtonViewModel: IconWithLabelButtonViewModel!
    var audioDeviceButtonViewModel: IconWithLabelButtonViewModel!

    var cameraStatus: LocalUserState.CameraOperationalStatus = .off
    var micStatus: LocalUserState.AudioOperationalStatus = .off
    var localVideoStreamId: String?

    private let dispatch: ActionDispatch

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
        self.micStatus = localUserState.audioState.operation
        self.cameraButtonViewModel.update(
            iconName: self.cameraStatus == .on ? .videoOn : .videoOff,
            buttonLabel: "Video is \(self.cameraStatus == .on ? "on" : "off")")
        self.cameraButtonViewModel.update(isDisabled: isCameraDisabled())
        self.micButtonViewModel.update(
            iconName: self.micStatus == .on ? .micOn : .micOff,
            buttonLabel: "Mic is \(self.micStatus == .on ? "on" : "off")")
        self.audioDeviceButtonViewModel.update(
            iconName: deviceIconFor(audioDeviceStatus: localUserState.audioState.device),
            buttonLabel: deviceLabelFor(audioDeviceStatus: localUserState.audioState.device))

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

    private func deviceIconFor(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus) -> CompositeIcon {
        switch audioDeviceStatus {
        case .receiverSelected:
            return .speakerRegular
        case .speakerSelected:
            return .speakerFilled
        default:
            return self.audioDeviceButtonViewModel.iconName
        }
    }

    private func deviceLabelFor(audioDeviceStatus: LocalUserState.AudioDeviceSelectionStatus) -> String {
        switch audioDeviceStatus {
        case .receiverSelected:
            return AudioDeviceType.receiver.name
        case .speakerSelected:
            return AudioDeviceType.speaker.name
        default:
            return self.audioDeviceButtonViewModel.buttonLabel
        }
    }
}
