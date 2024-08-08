//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class ControlBarViewModel: ObservableObject {
    private let logger: Logger
    private let localizationProvider: LocalizationProviderProtocol
    private let dispatch: ActionDispatch
    private var isCameraStateUpdating = false
    private var isDefaultUserStateMapped = false
    private(set) var cameraButtonViewModel: IconButtonViewModel!
    private let controlBarOptions: CallScreenControlBarOptions?

    @Published var cameraPermission: AppPermission.Status = .unknown
    @Published var isShareActivityDisplayed = false
    @Published var isDisplayed = false
    @Published var isCameraDisplayed = true

    var micButtonViewModel: IconButtonViewModel!
    var audioDeviceButtonViewModel: IconButtonViewModel!
    var hangUpButtonViewModel: IconButtonViewModel!
    var moreButtonViewModel: IconButtonViewModel!
    var debugInfoSharingActivityViewModel: DebugInfoSharingActivityViewModel!
    var callingStatus: CallingStatus = .none
    var operationStatus: OperationStatus = .none
    var cameraState = LocalUserState.CameraState(operation: .off,
                                                 device: .front,
                                                 transmission: .local)
    var audioState = LocalUserState.AudioState(operation: .off,
                                               device: .receiverSelected)
    var onEndCallTapped: (() -> Void)

    var capabilitiesManager: CapabilitiesManager
    var capabilities: Set<ParticipantCapabilityType>

    // swaftlint:disable function_body_length
    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         dispatchAction: @escaping ActionDispatch,
         onEndCallTapped: @escaping (() -> Void),
         localUserState: LocalUserState,
         audioVideoMode: CallCompositeAudioVideoMode,
         capabilitiesManager: CapabilitiesManager,
         controlBarOptions: CallScreenControlBarOptions?) {
        self.logger = logger
        self.localizationProvider = localizationProvider
        self.dispatch = dispatchAction
        self.onEndCallTapped = onEndCallTapped

        self.capabilitiesManager = capabilitiesManager
        self.capabilities = localUserState.capabilities
        self.controlBarOptions = controlBarOptions
        cameraButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .videoOff,
            buttonType: .controlButton,
            isDisabled: isCameraDisabled(),
            isVisible: isCameraVisible(audioVideoMode)) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Toggle camera button tapped")
                self.cameraButtonTapped()
        }

        cameraButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .videoOffAccessibilityLabel)

        micButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .micOff,
            buttonType: .controlButton,
            isDisabled: isMicDisabled(),
            isVisible: isMicVisible()) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Toggle microphone button tapped")
                self.microphoneButtonTapped()
        }

        micButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .micOffAccessibilityLabel)

        audioDeviceButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .speakerFilled,
            buttonType: .controlButton,
            isDisabled: false,
            isVisible: isAudioDeviceVisible()) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Select audio device button tapped")
                self.selectAudioDeviceButtonTapped()
        }

        audioDeviceButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .deviceAccesibiiltyLabel)

        hangUpButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .endCall,
            buttonType: .roundedRectButton,
            isDisabled: false,
            isVisible: true) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Hangup button tapped")
                self.onEndCallTapped()
        }

        hangUpButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .leaveCall)

        moreButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .more,
            buttonType: .controlButton,
            isDisabled: false,
            isVisible: isMoreButtonVisible()) { [weak self] in
                guard let self = self else {
                    return
                }
                self.moreButtonTapped()
        }

        moreButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .moreAccessibilityLabel)

        debugInfoSharingActivityViewModel = compositeViewModelFactory.makeDebugInfoSharingActivityViewModel()
    }

    func cameraButtonTapped() {
        guard !isCameraStateUpdating else {
            return
        }

        isCameraStateUpdating = true
        let action: LocalUserAction = cameraState.operation == .on ?
            .cameraOffTriggered : .cameraOnTriggered
        dispatch(.localUserAction(action))
    }

    func isMoreButtonVisible() -> Bool {
            controlBarOptions?.customButtons.isEmpty == false ||
            controlBarOptions?.liveCaptionsButtonOptions?.visible ?? true ||
            controlBarOptions?.liveCaptionsToggleButtonOptions?.visible ?? true ||
            controlBarOptions?.captionsLanguageButtonOptions?.visible ?? true ||
            controlBarOptions?.spokenLanguageButtonOptions?.visible ?? true ||
            controlBarOptions?.shareDiagnosticsButtonOptions?.visible ?? true ||
            controlBarOptions?.reportIssueButtonOptions?.visible ?? true
    }

    func isMicVisible() -> Bool {
        controlBarOptions?.microphoneButton?.visible ?? true
    }

    func isMicDisabled() -> Bool {
        controlBarOptions?.microphoneButton?.enabled == false ||
        audioState.operation == .pending ||
        callingStatus == .localHold ||
        isBypassLoadingOverlay() ||
        !self.capabilitiesManager.hasCapability(capabilities: self.capabilities,
                                                capability: ParticipantCapabilityType.unmuteMicrophone)
    }
    func isBypassLoadingOverlay() -> Bool {
        operationStatus == .skipSetupRequested &&
        callingStatus != .connected &&
        callingStatus != .inLobby
    }

    func isAudioDeviceVisible() -> Bool {
        controlBarOptions?.audioDeviceButton?.visible ?? true
    }
    func isAudioDeviceDisabled() -> Bool {
            controlBarOptions?.audioDeviceButton?.enabled == false ||
            callingStatus == .localHold ||
            isBypassLoadingOverlay()
    }

    func microphoneButtonTapped() {
        self.callCustomOnClickHandler(controlBarOptions?.microphoneButton)
        let action: LocalUserAction = audioState.operation == .on ?
        .microphoneOffTriggered : .microphoneOnTriggered
        dispatch(.localUserAction(action))
    }

    func selectAudioDeviceButtonTapped() {
        self.callCustomOnClickHandler(controlBarOptions?.audioDeviceButton)
        dispatch(.showAudioSelection)
    }

    func moreButtonTapped() {
        dispatch(.showMoreOptions)
    }
    func isMoreButtonDisabled() -> Bool {
            isBypassLoadingOverlay()
    }

    func isCameraVisible(_ audioVideoMode: CallCompositeAudioVideoMode) -> Bool {
        return audioVideoMode != .audioOnly &&
        controlBarOptions?.cameraButton?.visible ?? true
    }

    func isCameraDisabled() -> Bool {
        controlBarOptions?.cameraButton?.enabled == false ||
                cameraPermission == .denied ||
                cameraState.operation == .pending ||
                callingStatus == .localHold ||
                isCameraStateUpdating ||
                isBypassLoadingOverlay() ||
        !capabilitiesManager.hasCapability(capabilities: self.capabilities,
                                           capability: ParticipantCapabilityType.turnVideoOn)
    }

    func update(localUserState: LocalUserState,
                permissionState: PermissionState,
                callingState: CallingState,
                visibilityState: VisibilityState,
                navigationState: NavigationState
                ) {
        isShareActivityDisplayed = navigationState.supportShareSheetVisible
        callingStatus = callingState.status
        operationStatus = callingState.operationStatus
        self.capabilities = localUserState.capabilities
        if cameraPermission != permissionState.cameraPermission {
            cameraPermission = permissionState.cameraPermission
        }
        if isCameraStateUpdating,
           cameraState.operation != localUserState.cameraState.operation {
            isCameraStateUpdating = localUserState.cameraState.operation != .on &&
                                    localUserState.cameraState.operation != .off
        }
        cameraState = localUserState.cameraState
        cameraButtonViewModel.update(iconName: cameraState.operation == .on ? .videoOn : .videoOff)
        cameraButtonViewModel.update(accessibilityLabel: cameraState.operation == .on
                                     ? localizationProvider.getLocalizedString(.videoOnAccessibilityLabel)
                                     : localizationProvider.getLocalizedString(.videoOffAccessibilityLabel))
        cameraButtonViewModel.update(isDisabled: isCameraDisabled())

        audioState = localUserState.audioState
        micButtonViewModel.update(iconName: audioState.operation == .on ? .micOn : .micOff)
        micButtonViewModel.update(accessibilityLabel: audioState.operation == .on
                                     ? localizationProvider.getLocalizedString(.micOnAccessibilityLabel)
                                     : localizationProvider.getLocalizedString(.micOffAccessibilityLabel))
        micButtonViewModel.update(isDisabled: isMicDisabled())
        audioDeviceButtonViewModel.update(isDisabled: isAudioDeviceDisabled())
        let audioDeviceState = localUserState.audioState.device
        audioDeviceButtonViewModel.update(
            iconName: audioDeviceState.icon
        )
        audioDeviceButtonViewModel.update(
            accessibilityValue: audioDeviceState.getLabel(localizationProvider: localizationProvider))

        moreButtonViewModel.update(isDisabled: isMoreButtonDisabled())

        isDisplayed = visibilityState.currentStatus != .pipModeEntered
    }

    private func callCustomOnClickHandler(_ buttonOptions: ButtonOptions?) {
        guard let buttonOptions = buttonOptions else {
            return
        }
        buttonOptions.onClick?(buttonOptions)
    }
}
