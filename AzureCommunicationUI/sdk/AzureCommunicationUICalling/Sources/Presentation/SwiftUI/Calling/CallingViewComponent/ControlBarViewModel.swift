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
    private var isCameraStateUpdating: Bool = false
    private(set) var cameraButtonViewModel: IconButtonViewModel!

    @Published var cameraPermission: AppPermission.Status = .unknown
    @Published var isAudioDeviceSelectionDisplayed: Bool = false
    @Published var isConfirmLeaveListDisplayed: Bool = false
    @Published var isMoreCallOptionsListDisplayed: Bool = false
    @Published var isShareActivityDisplayed: Bool = false

    let audioDevicesListViewModel: AudioDevicesListViewModel
    var micButtonViewModel: IconButtonViewModel!
    var audioDeviceButtonViewModel: IconButtonViewModel!
    var hangUpButtonViewModel: IconButtonViewModel!
    var moreButtonViewModel: IconButtonViewModel!
    var moreCallOptionsListViewModel: MoreCallOptionsListViewModel!
    var debugInfoSharingActivityViewModel: DebugInfoSharingActivityViewModel!
    var callingStatus: CallingStatus = .none
    var cameraState = LocalUserState.CameraState(operation: .off,
                                                 device: .front,
                                                 transmission: .local)
    var audioState = LocalUserState.AudioState(operation: .off,
                                               device: .receiverSelected)
    var displayEndCallConfirm: (() -> Void)

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         dispatchAction: @escaping ActionDispatch,
         endCallConfirm: @escaping (() -> Void),
         localUserState: LocalUserState) {
        self.logger = logger
        self.localizationProvider = localizationProvider
        self.dispatch = dispatchAction
        self.displayEndCallConfirm = endCallConfirm

        audioDevicesListViewModel = compositeViewModelFactory.makeAudioDevicesListViewModel(
            dispatchAction: dispatch,
            localUserState: localUserState)
        cameraButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .videoOff,
            buttonType: .controlButton,
            isDisabled: false) { [weak self] in
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
            isDisabled: false) { [weak self] in
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
            isDisabled: false) { [weak self] in
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
            isDisabled: false) {
                [weak self] in
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
            })
        debugInfoSharingActivityViewModel = compositeViewModelFactory.makeDebugInfoSharingActivityViewModel()
    }

    func endCallButtonTapped() {
        self.isConfirmLeaveListDisplayed = true
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

    func microphoneButtonTapped() {
        let action: LocalUserAction = audioState.operation == .on ?
        .microphoneOffTriggered : .microphoneOnTriggered
        dispatch(.localUserAction(action))
    }

    func selectAudioDeviceButtonTapped() {
        self.isAudioDeviceSelectionDisplayed = true
    }

    func moreButtonTapped() {
        isMoreCallOptionsListDisplayed = true
    }

    func dismissConfirmLeaveDrawerList() {
        self.isConfirmLeaveListDisplayed = false
    }

    func isCameraDisabled() -> Bool {
        cameraPermission == .denied || cameraState.operation == .pending ||
        callingStatus == .localHold || isCameraStateUpdating
    }

    func isMicDisabled() -> Bool {
        audioState.operation == .pending || callingStatus == .localHold
    }

    func isAudioDeviceDisabled() -> Bool {
        callingStatus == .localHold
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
                callingState: CallingState) {
        callingStatus = callingState.status
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
    }
}
