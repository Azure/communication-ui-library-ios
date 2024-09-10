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
    private let audioVideoMode: CallCompositeAudioVideoMode

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
         controlBarOptions: CallScreenControlBarOptions?,
         buttonViewDataState: ButtonViewDataState) {
        self.logger = logger
        self.localizationProvider = localizationProvider
        self.dispatch = dispatchAction
        self.onEndCallTapped = onEndCallTapped
        self.audioVideoMode = audioVideoMode

        self.capabilitiesManager = capabilitiesManager
        self.capabilities = localUserState.capabilities
        self.controlBarOptions = controlBarOptions
        cameraButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .videoOff,
            buttonType: .controlButton,
            isDisabled: isCameraDisabled(buttonViewDataState),
            isVisible: isCameraVisible(buttonViewDataState)) { [weak self] in
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
            isDisabled: isMicDisabled(buttonViewDataState),
            isVisible: isMicVisible(buttonViewDataState)) { [weak self] in
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
            isVisible: isAudioDeviceVisible(buttonViewDataState)) { [weak self] in
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
            isVisible: isMoreButtonVisible(buttonViewDataState)) { [weak self] in
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

    private func isMoreButtonVisible(_ buttonViewDataState: ButtonViewDataState) -> Bool {
        buttonViewDataState.callScreenCustomButtonsState.isEmpty == false ||
        buttonViewDataState.liveCaptionsButton?.visible ?? true ||
        buttonViewDataState.liveCaptionsToggleButton?.visible ?? true ||
        buttonViewDataState.captionsLanguageButton?.visible ?? true ||
        buttonViewDataState.spokenLanguageButton?.visible ?? true ||
        buttonViewDataState.shareDiagnosticsButton?.visible ?? true ||
        buttonViewDataState.reportIssueButton?.visible ?? true
    }

    private func isMicVisible(_ buttonViewDataState: ButtonViewDataState) -> Bool {
        buttonViewDataState.callScreenMicButtonState?.visible ?? true
    }

    private func isMicDisabled(_ buttonViewDataState: ButtonViewDataState) -> Bool {
        buttonViewDataState.callScreenMicButtonState?.enabled == false ||
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

    private func isAudioDeviceVisible(_ buttonViewDataState: ButtonViewDataState) -> Bool {
        buttonViewDataState.callScreenAudioDeviceButtonState?.visible ?? true
    }
    private func isAudioDeviceDisabled(_ buttonViewDataState: ButtonViewDataState) -> Bool {
        buttonViewDataState.callScreenAudioDeviceButtonState?.enabled == false ||
        callingStatus == .localHold ||
        isBypassLoadingOverlay()
    }

    private func microphoneButtonTapped() {
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

    func isCameraVisible(_ buttonViewDataState: ButtonViewDataState) -> Bool {
        return audioVideoMode != .audioOnly &&
        buttonViewDataState.callScreenCameraButtonState?.visible ?? true
    }

    func isCameraDisabled(_ buttonViewDataState: ButtonViewDataState) -> Bool {
        buttonViewDataState.callScreenCameraButtonState?.enabled == false ||
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
                navigationState: NavigationState,
                buttonViewDataState: ButtonViewDataState
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
        cameraButtonViewModel.update(isDisabled: isCameraDisabled(buttonViewDataState))
        cameraButtonViewModel.update(isVisible: isCameraVisible(buttonViewDataState))

        audioState = localUserState.audioState
        micButtonViewModel.update(iconName: audioState.operation == .on ? .micOn : .micOff)
        micButtonViewModel.update(accessibilityLabel: audioState.operation == .on
                                     ? localizationProvider.getLocalizedString(.micOnAccessibilityLabel)
                                     : localizationProvider.getLocalizedString(.micOffAccessibilityLabel))
        micButtonViewModel.update(isDisabled: isMicDisabled(buttonViewDataState))
        micButtonViewModel.update(isVisible: isMicVisible(buttonViewDataState))
        audioDeviceButtonViewModel.update(isDisabled: isAudioDeviceDisabled(buttonViewDataState))
        let audioDeviceState = localUserState.audioState.device
        audioDeviceButtonViewModel.update(
            iconName: audioDeviceState.icon
        )
        audioDeviceButtonViewModel.update(
            accessibilityValue: audioDeviceState.getLabel(localizationProvider: localizationProvider))
        audioDeviceButtonViewModel.update(isVisible: isAudioDeviceVisible(buttonViewDataState))

        moreButtonViewModel.update(isDisabled: isMoreButtonDisabled())
        moreButtonViewModel.update(isVisible: isMoreButtonVisible(buttonViewDataState))

        isDisplayed = visibilityState.currentStatus != .pipModeEntered
    }

    func callCustomOnClickHandler(_ button: ButtonViewData?) {
        guard let button = button else {
            return
        }
        button.onClick?(button)
    }
}
