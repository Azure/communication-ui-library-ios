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
    private let localizationProvider: LocalizationProviderProtocol

    private var isJoinRequested: Bool = false
    private var callingStatus: CallingStatus = .none
    private var cameraStatus: LocalUserState.CameraOperationalStatus = .off
    private(set) var micStatus: LocalUserState.AudioOperationalStatus = .off
    private var localVideoStreamId: String?
    private(set) var cameraButtonViewModel: IconWithLabelButtonViewModel<CameraButtonState>!
    private(set) var micButtonViewModel: IconWithLabelButtonViewModel<MicButtonState>!
    private(set) var audioDeviceButtonViewModel: IconWithLabelButtonViewModel<AudioButtonState>!

    let audioDevicesListViewModel: AudioDevicesListViewModel

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         dispatchAction: @escaping ActionDispatch,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol) {
        self.logger = logger
        self.dispatch = dispatchAction
        self.localizationProvider = localizationProvider

        audioDevicesListViewModel = compositeViewModelFactory.makeAudioDevicesListViewModel(
            dispatchAction: dispatchAction,
            localUserState: localUserState)

        cameraButtonViewModel = compositeViewModelFactory.makeIconWithLabelButtonViewModel(
            selectedButtonState: CameraButtonState.videoOff,
            localizationProvider: self.localizationProvider,
            buttonTypeColor: .colorThemedWhite,
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
            selectedButtonState: MicButtonState.micOff,
            localizationProvider: self.localizationProvider,
            buttonTypeColor: .colorThemedWhite,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Toggle microphone button tapped")
                self.microphoneButtonTapped()
        }
        micButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(.micOffAccessibilityLabel)

        audioDeviceButtonViewModel = compositeViewModelFactory.makeIconWithLabelButtonViewModel(
            selectedButtonState: AudioButtonState.speaker,
            localizationProvider: self.localizationProvider,
            buttonTypeColor: .colorThemedWhite,
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
            dispatch(.localUserAction(.cameraPreviewOnTriggered))
        case (false, false):
            dispatch(.localUserAction(.cameraOnTriggered))
        case (true, _):
            dispatch(.localUserAction(.cameraOffTriggered))
        }
    }

    func microphoneButtonTapped() {
        let isPreview = callingStatus == .none
        let isMicOn = micStatus == .on
        switch (isMicOn, isPreview) {
        case (false, true):
            dispatch(.localUserAction(.microphonePreviewOn))
        case (false, false):
            dispatch(.localUserAction(.microphoneOnTriggered))
        case (true, true):
            dispatch(.localUserAction(.microphonePreviewOff))
        case (true, false):
            dispatch(.localUserAction(.microphoneOffTriggered))
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
            selectedButtonState: cameraStatus == .on ? CameraButtonState.videoOn : CameraButtonState.videoOff)
        cameraButtonViewModel.update(accessibilityLabel: cameraStatus == .on
                                     ? localizationProvider.getLocalizedString(.videoOnAccessibilityLabel)
                                     : localizationProvider.getLocalizedString(.videoOffAccessibilityLabel))
        cameraButtonViewModel.update(isDisabled: isCameraDisabled())

        micButtonViewModel.update(
            selectedButtonState: micStatus == .on ? MicButtonState.micOn : MicButtonState.micOff)
        micButtonViewModel.update(accessibilityLabel: micStatus == .on
                                     ? localizationProvider.getLocalizedString(.micOnAccessibilityLabel)
                                     : localizationProvider.getLocalizedString(.micOffAccessibilityLabel))
        micButtonViewModel.update(isDisabled: isAudioDisabled())

        let audioDeviceStatus = localUserState.audioState.device
        audioDeviceButtonViewModel.update(
            selectedButtonState: AudioButtonState.getButtonState(from: audioDeviceStatus))
        audioDeviceButtonViewModel.update(
            accessibilityValue: audioDeviceStatus.getLabel(localizationProvider: localizationProvider))
    }

    private func updateButtonTypeColor(isLocalVideoOff: Bool) {
        let cameraButtonTypeColor: IconWithLabelButtonViewModel<CameraButtonState>.ButtonTypeColor
                                    = isLocalVideoOff ? .colorThemedWhite : .white
        let micButtonTypeColor: IconWithLabelButtonViewModel<MicButtonState>.ButtonTypeColor
                                    = isLocalVideoOff ? .colorThemedWhite : .white
        let audioButtonTypeColor: IconWithLabelButtonViewModel<AudioButtonState>.ButtonTypeColor
                                    = isLocalVideoOff ? .colorThemedWhite : .white

        cameraButtonViewModel.update(buttonTypeColor: cameraButtonTypeColor)
        micButtonViewModel.update(buttonTypeColor: micButtonTypeColor)
        audioDeviceButtonViewModel.update(buttonTypeColor: audioButtonTypeColor)
    }
}
