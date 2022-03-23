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
	private let localizationProvider: LocalizationProvider

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
         localUserState: LocalUserState,
         localizationProvider: LocalizationProvider) {
        self.logger = logger
        self.dispatch = dispatchAction
        self.localizationProvider = localizationProvider

        audioDevicesListViewModel = compositeViewModelFactory.makeAudioDevicesListViewModel(
            dispatchAction: dispatchAction,
            localUserState: localUserState)

        cameraButtonViewModel = compositeViewModelFactory.makeIconWithLabelButtonViewModel(
            iconName: .videoOff,
            buttonTypeColor: .colorThemedWhite,
            buttonLabel: self.localizationProvider
                .getLocalizedString(.videoOff),
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Toggle camera button tapped")
                self.videoButtonTapped()
        }
        cameraButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .videoOffAccessibilityLabel)

        micButtonViewModel = compositeViewModelFactory.makeIconWithLabelButtonViewModel(
            iconName: .micOff,
            buttonTypeColor: .colorThemedWhite,
            buttonLabel: self.localizationProvider
                .getLocalizedString(.micOff),
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Toggle microphone button tapped")
                self.microphoneButtonTapped()
        }
        micButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(.micOffAccessibilityLabel)

        audioDeviceButtonViewModel = compositeViewModelFactory.makeIconWithLabelButtonViewModel(
            iconName: .speakerFilled,
            buttonTypeColor: .colorThemedWhite,
            buttonLabel: self.localizationProvider
                .getLocalizedString(.device),
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Select audio device button tapped")
                self.selectAudioDeviceButtonTapped()
        }
        audioDeviceButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .deviceAccesibiiltyLabel)
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
            iconName: cameraStatus == .on ? .videoOn : .videoOff,
            buttonLabel: cameraStatus == .on
            ? localizationProvider.getLocalizedString(.videoOn)
            : localizationProvider.getLocalizedString(.videoOff))
        cameraButtonViewModel.update(accessibilityLabel: cameraStatus == .on
                                     ? localizationProvider.getLocalizedString(.videoOnAccessibilityLabel)
                                     : localizationProvider.getLocalizedString(.videoOffAccessibilityLabel))
        cameraButtonViewModel.update(isDisabled: isCameraDisabled())

        micButtonViewModel.update(
            iconName: micStatus == .on ? .micOn : .micOff,
            buttonLabel: micStatus == .on
            ? localizationProvider.getLocalizedString(.micOn)
            : localizationProvider.getLocalizedString(.micOff))
        micButtonViewModel.update(accessibilityLabel: micStatus == .on
                                     ? localizationProvider.getLocalizedString(.micOnAccessibilityLabel)
                                     : localizationProvider.getLocalizedString(.micOffAccessibilityLabel))
        micButtonViewModel.update(isDisabled: isAudioDisabled())

        let audioDeviceStatus = localUserState.audioState.device
        audioDeviceButtonViewModel.update(
            iconName: audioDeviceStatus.icon,
            buttonLabel: audioDeviceStatus.getLabel(localizationProvider: localizationProvider))
        audioDeviceButtonViewModel.update(
            accessibilityValue: audioDeviceStatus.getLabel(localizationProvider: localizationProvider))
    }

    private func updateButtonTypeColor(isLocalVideoOff: Bool) {
        let buttonTypeColor: IconWithLabelButtonViewModel.ButtonTypeColor
            = isLocalVideoOff ? .colorThemedWhite : .white
        cameraButtonViewModel.update(buttonTypeColor: buttonTypeColor)
        micButtonViewModel.update(buttonTypeColor: buttonTypeColor)
        audioDeviceButtonViewModel.update(buttonTypeColor: buttonTypeColor)
    }
}
