//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ControlBarViewModel: ObservableObject {
    @Published var cameraPermission: AppPermission.Status = .unknown
    @Published var isAudioDeviceSelectionDisplayed: Bool = false

    let audioDeviceListViewModel: AudioDeviceListViewModel
    var cameraButtonViewModel: IconButtonViewModel!
    var micButtonViewModel: IconButtonViewModel!
    var audioDeviceButtonViewModel: IconButtonViewModel!
    var hangUpButtonViewModel: IconButtonViewModel!

    var cameraState = LocalUserState.CameraState(operation: .off,
                                                 device: .front,
                                                 transmission: .local)
    var audioState = LocalUserState.AudioState(operation: .off,
                                               device: .receiverSelected)

    var displayEndCallConfirm: (() -> Void)
    private let logger: Logger
    private let dispatch: ActionDispatch

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         dispatchAction: @escaping ActionDispatch,
         endCallConfirm: @escaping (() -> Void),
         localUserState: LocalUserState) {
        self.logger = logger
        self.dispatch = dispatchAction
        self.displayEndCallConfirm = endCallConfirm
        self.audioDeviceListViewModel = compositeViewModelFactory.makeAudioDeviceListViewModel(
            dispatchAction: dispatch,
            localUserState: localUserState)
        self.cameraButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .videoOff,
            buttonType: .controlButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Toggle camera button tapped")
                self.cameraButtonTapped()
        }
        self.micButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .micOff,
            buttonType: .controlButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("-----Toggle microphone button tapped")
                self.microphoneButtonTapped()
        }
        self.audioDeviceButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .speakerFilled,
            buttonType: .controlButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Select audio device button tapped")
                self.selectAudioDeviceButtonTapped()
        }

        self.hangUpButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .endCall,
            buttonType: .roundedRectButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Hangup button tapped")
                self.endCallButtonTapped()
        }
    }

    func endCallButtonTapped() {
        displayEndCallConfirm()
    }

    func cameraButtonTapped() {
        let action: Action = cameraState.operation == .on ?
            LocalUserAction.CameraOffTriggered() : LocalUserAction.CameraOnTriggered()
        dispatch(action)
    }

    func microphoneButtonTapped() {
        let action: Action = audioState.operation == .on ?
            LocalUserAction.MicrophoneOffTriggered() : LocalUserAction.MicrophoneOnTriggered()
        dispatch(action)
    }

    func selectAudioDeviceButtonTapped() {
        self.isAudioDeviceSelectionDisplayed = true
    }

    func isCameraDisabled() -> Bool {
        cameraPermission == .denied || cameraState.operation == .pending
    }

    func isMicDisabled() -> Bool {
        audioState.operation == .pending
    }

    func update(localUserState: LocalUserState, permissionState: PermissionState) {
        if cameraPermission != permissionState.cameraPermission {
            cameraPermission = permissionState.cameraPermission
        }

        cameraState = localUserState.cameraState
        audioState = localUserState.audioState
        cameraButtonViewModel.update(iconName: cameraState.operation == .on ? .videoOn : .videoOff)
        cameraButtonViewModel.update(isDisabled: isCameraDisabled())
        micButtonViewModel.update(iconName: audioState.operation == .on ? .micOn : .micOff)
        micButtonViewModel.update(isDisabled: isMicDisabled())
        audioDeviceButtonViewModel.update(
            iconName: deviceIconFor(audioDeviceStatus: localUserState.audioState.device)
        )
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
}
