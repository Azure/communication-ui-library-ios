//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

// swiftlint:disable type_body_length
class ControlBarViewModel: ObservableObject {
    private let logger: Logger
    private let localizationProvider: LocalizationProviderProtocol
    private let dispatch: ActionDispatch
    private var isCameraStateUpdating = false
    private var isDefaultUserStateMapped = false
    private(set) var cameraButtonViewModel: IconButtonViewModel!
    private let controlBarOptions: CallScreenControlBarOptions?

    @Published var cameraPermission: AppPermission.Status = .unknown
    @Published var isAudioDeviceSelectionDisplayed = false
    @Published var isConfirmLeaveListDisplayed = false
    @Published var isMoreCallOptionsListDisplayed = false
    @Published var isShareActivityDisplayed = false
    @Published var isSupportFormOptionDisplayed = false
    @Published var isDisplayed = false

    let audioDevicesListViewModel: AudioDevicesListViewModel
    var micButtonViewModel: IconButtonViewModel!
    var audioDeviceButtonViewModel: IconButtonViewModel!
    var hangUpButtonViewModel: IconButtonViewModel!
    var moreButtonViewModel: IconButtonViewModel!
    var moreCallOptionsListViewModel: MoreCallOptionsListViewModel!
    var debugInfoSharingActivityViewModel: DebugInfoSharingActivityViewModel!
    var callingStatus: CallingStatus = .none
    var operationStatus: OperationStatus = .none
    var cameraState = LocalUserState.CameraState(operation: .off,
                                                 device: .front,
                                                 transmission: .local)
    var audioState = LocalUserState.AudioState(operation: .off,
                                               device: .receiverSelected)
    var displayEndCallConfirm: (() -> Void)
    var capabilitiesManager: CapabilitiesManager
    var capabilities: Set<ParticipantCapabilityType>

    // swiftlint:disable function_body_length
    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         dispatchAction: @escaping ActionDispatch,
         endCallConfirm: @escaping (() -> Void),
         localUserState: LocalUserState,
         audioVideoMode: CallCompositeAudioVideoMode,
         capabilitiesManager: CapabilitiesManager,
         controlBarOptions: CallScreenControlBarOptions?) {
        self.logger = logger
        self.localizationProvider = localizationProvider
        self.dispatch = dispatchAction
        self.displayEndCallConfirm = endCallConfirm
        self.capabilitiesManager = capabilitiesManager
        self.capabilities = localUserState.capabilities
        self.controlBarOptions = controlBarOptions
        audioDevicesListViewModel = compositeViewModelFactory.makeAudioDevicesListViewModel(
            dispatchAction: dispatch,
            localUserState: localUserState)

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
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Hangup button tapped")
                self.endCallButtonTapped()
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

        moreCallOptionsListViewModel = compositeViewModelFactory.makeMoreCallOptionsListViewModel(
            showSharingViewAction: { [weak self] in
                guard let self = self else {
                    return
                }
                self.isShareActivityDisplayed = true
            },
            showSupportFormAction: { [weak self] in
                guard let self = self else {
                    return
                }
                self.dispatch(.showSupportForm)
            }
        )

        debugInfoSharingActivityViewModel = compositeViewModelFactory.makeDebugInfoSharingActivityViewModel()
    }
    // swiftlint:enable function_body_length

    func endCallButtonTapped() {
        if self.controlBarOptions?.leaveCallConfirmationMode == .alwaysDisabled {
            self.displayEndCallConfirm()
        } else {
            self.isConfirmLeaveListDisplayed = true
        }
    }

    func cameraButtonTapped() {
        guard !isCameraStateUpdating else {
            return
        }

        self.callCustomOnClickHandler(controlBarOptions?.cameraButton)
        isCameraStateUpdating = true
        let action: LocalUserAction = cameraState.operation == .on ?
            .cameraOffTriggered : .cameraOnTriggered
        dispatch(.localUserAction(action))
    }

    func microphoneButtonTapped() {
        self.callCustomOnClickHandler(controlBarOptions?.microphoneButton)

        let action: LocalUserAction = audioState.operation == .on ?
        .microphoneOffTriggered : .microphoneOnTriggered
        dispatch(.localUserAction(action))
    }

    func selectAudioDeviceButtonTapped() {
        self.callCustomOnClickHandler(controlBarOptions?.audioDeviceButton)
        self.isAudioDeviceSelectionDisplayed = true
    }

    func moreButtonTapped() {
        isMoreCallOptionsListDisplayed = true
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

    func dismissConfirmLeaveDrawerList() {
        self.isConfirmLeaveListDisplayed = false
    }

    func isMoreButtonDisabled() -> Bool {
        isBypassLoadingOverlay()
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

    func isAudioDeviceVisible() -> Bool {
        controlBarOptions?.audioDeviceButton?.visible ?? true
    }

    func isAudioDeviceDisabled() -> Bool {
        controlBarOptions?.audioDeviceButton?.enabled == false ||
        callingStatus == .localHold ||
        isBypassLoadingOverlay()
    }

    func isBypassLoadingOverlay() -> Bool {
        operationStatus == .skipSetupRequested &&
        callingStatus != .connected &&
        callingStatus != .inLobby
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

    func getLeaveCallButtonViewModel() -> DrawerListItemViewModel {
        return DrawerListItemViewModel(
            icon: .endCallRegular,
            title: localizationProvider.getLocalizedString(.leaveCall),
            accessibilityIdentifier: AccessibilityIdentifier.leaveCallAccessibilityID.rawValue,
            action: { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Leave call button tapped")
                self.displayEndCallConfirm()
            })
    }

    func getCancelButtonViewModel() -> DrawerListItemViewModel {
        return DrawerListItemViewModel(
            icon: .dismiss,
            title: localizationProvider.getLocalizedString(.cancel),
            accessibilityIdentifier: AccessibilityIdentifier.cancelAccessibilityID.rawValue,
            action: { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Cancel button tapped")
                self.dismissConfirmLeaveDrawerList()
            })
    }

    func getLeaveCallConfirmationListViewModel() -> LeaveCallConfirmationListViewModel {
        let leaveCallConfirmationVm: [DrawerListItemViewModel] = [
            getLeaveCallButtonViewModel(),
            getCancelButtonViewModel()
        ]
        let headerName = localizationProvider.getLocalizedString(.leaveCallListHeader)
        return LeaveCallConfirmationListViewModel(headerName: headerName,
                                                  listItemViewModel: leaveCallConfirmationVm)
    }

    func update(localUserState: LocalUserState,
                permissionState: PermissionState,
                callingState: CallingState,
                visibilityState: VisibilityState) {
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
        audioDevicesListViewModel.update(audioDeviceStatus: audioDeviceState)

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
// swiftlint:enable type_body_length
