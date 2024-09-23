//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation
import UIKit
import SwiftUI

// swiftlint:disable type_body_length
class ControlBarViewModel: ObservableObject {
    private let logger: Logger
    private let localizationProvider: LocalizationProviderProtocol
    private let dispatch: ActionDispatch
    private var isCameraStateUpdating = false
    private var isDefaultUserStateMapped = false
    private(set) var cameraButtonViewModel: IconButtonViewModel!
    private let controlBarOptions: CallScreenControlBarOptions?
    private let audioVideoMode: CallCompositeAudioVideoMode
    var onDrawerViewDidDisappearBlock: (() -> Void)?
    private let accessibilityProvider: AccessibilityProviderProtocol
    @Published var cameraPermission: AppPermission.Status = .unknown
    @Published var isShareActivityDisplayed = false
    @Published var isDisplayed = false
    @Published var isCameraDisplayed = true
    @Published var totalButtonCount = 5
    @Published var isMoreButtonShouldFocused = false
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
    var buttonViewDataState = ButtonViewDataState()

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
         accessibilityProvider: AccessibilityProviderProtocol,
         audioVideoMode: CallCompositeAudioVideoMode,
         capabilitiesManager: CapabilitiesManager,
         controlBarOptions: CallScreenControlBarOptions?,
         buttonViewDataState: ButtonViewDataState) {
        self.logger = logger
        self.localizationProvider = localizationProvider
        self.dispatch = dispatchAction
        self.onEndCallTapped = onEndCallTapped
        self.audioVideoMode = audioVideoMode
        self.accessibilityProvider = accessibilityProvider
        self.capabilitiesManager = capabilitiesManager
        self.capabilities = localUserState.capabilities
        self.controlBarOptions = controlBarOptions
        self.buttonViewDataState = buttonViewDataState
        setupCameraButtonViewModel(factory: compositeViewModelFactory)
        setupMicButtonViewModel(factory: compositeViewModelFactory)
        setupAudioDeviceButtonViewModel(factory: compositeViewModelFactory)
        setupHangUpButtonViewModel(factory: compositeViewModelFactory)
        setupMoreButtonViewModel(factory: compositeViewModelFactory)

        debugInfoSharingActivityViewModel = compositeViewModelFactory.makeDebugInfoSharingActivityViewModel()
        updateTotalButtonCount()
        accessibilityProvider.subscribeToUIFocusDidUpdateNotification(self)
        accessibilityProvider.subscribeToVoiceOverStatusDidChangeNotification(self)
    }

    private func setupCameraButtonViewModel(factory: CompositeViewModelFactoryProtocol) {
        cameraButtonViewModel = factory.makeIconButtonViewModel(
            iconName: .videoOff,
            buttonType: .controlButton,
            isDisabled: isCameraDisabled(),
            isVisible: isCameraVisible()) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Toggle camera button tapped")
                self.cameraButtonTapped()
        }
        cameraButtonViewModel.accessibilityLabel = localizationProvider.getLocalizedString(.videoOffAccessibilityLabel)
    }

    private func setupMicButtonViewModel(factory: CompositeViewModelFactoryProtocol) {
        micButtonViewModel = factory.makeIconButtonViewModel(
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
        micButtonViewModel.accessibilityLabel = localizationProvider.getLocalizedString(.micOffAccessibilityLabel)
    }

    private func setupAudioDeviceButtonViewModel(factory: CompositeViewModelFactoryProtocol) {
        audioDeviceButtonViewModel = factory.makeIconButtonViewModel(
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
        audioDeviceButtonViewModel.accessibilityLabel = localizationProvider.getLocalizedString(
            .deviceAccesibiiltyLabel
        )
    }

    private func setupHangUpButtonViewModel(factory: CompositeViewModelFactoryProtocol) {
        hangUpButtonViewModel = factory.makeIconButtonViewModel(
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
        hangUpButtonViewModel.accessibilityLabel = localizationProvider.getLocalizedString(.leaveCall)
    }

    private func setupMoreButtonViewModel(factory: CompositeViewModelFactoryProtocol) {
        moreButtonViewModel = factory.makeIconButtonViewModel(
            iconName: .more,
            buttonType: .controlButton,
            isDisabled: false,
            isVisible: isMoreButtonVisible()) { [weak self] in
                guard let self = self else {
                    return
                }
                self.moreButtonTapped()
        }
        moreButtonViewModel.accessibilityLabel = localizationProvider.getLocalizedString(.moreAccessibilityLabel)
    }

    func setAccessibilityFocus(_ focusType: any View) {
            UIAccessibility.post(notification: .layoutChanged, argument: focusType)
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
        buttonViewDataState.callScreenCustomButtonsState.filter({ button in button.visible }).isEmpty == false ||
        buttonViewDataState.liveCaptionsButton?.visible ?? true ||
        buttonViewDataState.liveCaptionsToggleButton?.visible ?? true ||
        buttonViewDataState.captionsLanguageButton?.visible ?? true ||
        buttonViewDataState.spokenLanguageButton?.visible ?? true ||
        buttonViewDataState.shareDiagnosticsButton?.visible ?? true ||
        buttonViewDataState.reportIssueButton?.visible ?? true
    }

    func isMicVisible() -> Bool {
        buttonViewDataState.callScreenMicButtonState?.visible ?? true
    }

    func isMicDisabled() -> Bool {
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

    func isAudioDeviceVisible() -> Bool {
        buttonViewDataState.callScreenAudioDeviceButtonState?.visible ?? true
    }
    func isAudioDeviceDisabled() -> Bool {
        buttonViewDataState.callScreenAudioDeviceButtonState?.enabled == false ||
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
        NotificationCenter.default.addObserver(
            forName: Notification.Name(NotificationCenterName.drawerViewDidDisappear.rawValue),
            object: nil, queue: .main) { _ in
            self.onDrawerViewDidDisappearBlock?()
        }
        dispatch(.showMoreOptions)
    }
    func isMoreButtonDisabled() -> Bool {
            isBypassLoadingOverlay()
    }

    func isCameraVisible() -> Bool {
        return audioVideoMode != .audioOnly &&
        buttonViewDataState.callScreenCameraButtonState?.visible ?? true
    }

    func isCameraDisabled() -> Bool {
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
        self.buttonViewDataState = buttonViewDataState
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
        cameraButtonViewModel.update(isVisible: isCameraVisible())

        audioState = localUserState.audioState
        micButtonViewModel.update(iconName: audioState.operation == .on ? .micOn : .micOff)
        micButtonViewModel.update(accessibilityLabel: audioState.operation == .on
                                     ? localizationProvider.getLocalizedString(.micOnAccessibilityLabel)
                                     : localizationProvider.getLocalizedString(.micOffAccessibilityLabel))
        micButtonViewModel.update(isDisabled: isMicDisabled())
        micButtonViewModel.update(isVisible: isMicVisible())
        audioDeviceButtonViewModel.update(isDisabled: isAudioDeviceDisabled())
        let audioDeviceState = localUserState.audioState.device
        audioDeviceButtonViewModel.update(
            iconName: audioDeviceState.icon
        )
        audioDeviceButtonViewModel.update(
            accessibilityValue: audioDeviceState.getLabel(localizationProvider: localizationProvider))
        audioDeviceButtonViewModel.update(isVisible: isAudioDeviceVisible())

        moreButtonViewModel.update(isDisabled: isMoreButtonDisabled())
        moreButtonViewModel.update(isVisible: isMoreButtonVisible())
        print("update init called")
        isDisplayed = visibilityState.currentStatus != .pipModeEntered
        isMoreButtonShouldFocused = true
        updateTotalButtonCount()
    }

    func callCustomOnClickHandler(_ button: ButtonViewData?) {
        guard let button = button else {
            return
        }
        button.onClick?(button)
    }

    private func updateTotalButtonCount() {
        // we always have a hangUp button
        var newCount = 1
        if cameraButtonViewModel.isVisible {
            newCount += 1
        }
        if micButtonViewModel.isVisible {
            newCount += 1
        }
        if audioDeviceButtonViewModel.isVisible {
            newCount += 1
        }
        if moreButtonViewModel.isVisible {
            newCount += 1
        }
        if newCount != totalButtonCount {
            totalButtonCount = newCount
        }
    }
}
// swiftlint:enable type_body_length

extension ControlBarViewModel: AccessibilityProviderNotificationsObserver {
    func didChangeVoiceOverStatus(_ notification: NSNotification) {
        // Call the closure to handle the drawer view disappearance
        onDrawerViewDidDisappearBlock?()
    }
    func didUIFocusUpdateNotification(_ notification: NSNotification) {
        // Call the closure to handle the drawer view disappearance
        onDrawerViewDidDisappearBlock?()
    }
}
