//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class LocalVideoViewModel: ObservableObject {
    private let logger: Logger
    private let localizationProvider: LocalizationProviderProtocol
    private let dispatch: ActionDispatch

    @Published var localVideoStreamId: String?
    @Published var displayName: String?
    @Published var isMuted: Bool = false
    @Published var cameraOperationalStatus: LocalUserState.CameraOperationalStatus = .off

    var cameraSwitchButtonPipViewModel: IconButtonViewModel!
    var cameraSwitchButtonFullViewModel: IconButtonViewModel!

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         dispatchAction: @escaping ActionDispatch) {
        self.logger = logger
        self.localizationProvider = localizationProvider
        self.dispatch = dispatchAction

        cameraSwitchButtonPipViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .cameraSwitch,
            buttonType: .cameraSwitchButtonPip,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.toggleCameraSwitchTapped()
        }
        cameraSwitchButtonFullViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .cameraSwitch,
            buttonType: .cameraSwitchButtonFull,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.toggleCameraSwitchTapped()
        }
    }

    func toggleCameraSwitchTapped() {
        dispatch(.localUserAction(.cameraSwitchTriggered))
    }

    func update(localUserState: LocalUserState) {
        if localVideoStreamId != localUserState.localVideoStreamIdentifier {
            localVideoStreamId = localUserState.localVideoStreamIdentifier
        }

        if displayName != localUserState.displayName {
            displayName = localUserState.displayName
        }

        if cameraOperationalStatus != localUserState.cameraState.operation {
            cameraOperationalStatus = localUserState.cameraState.operation
        }

        cameraSwitchButtonPipViewModel.update(isDisabled: localUserState.cameraState.device == .switching)
        cameraSwitchButtonPipViewModel.update(accessibilityLabel: localUserState.cameraState.device == .front
                                              ? localizationProvider.getLocalizedString(.frontCamera)
                                              : localizationProvider.getLocalizedString(.backCamera))

        cameraSwitchButtonFullViewModel.update(isDisabled: localUserState.cameraState.device == .switching)
        cameraSwitchButtonFullViewModel.update(accessibilityLabel: localUserState.cameraState.device == .front
                                               ? localizationProvider.getLocalizedString(.frontCamera)
                                               : localizationProvider.getLocalizedString(.backCamera))

        let showMuted = localUserState.audioState.operation != .on
        if isMuted != showMuted {
            isMuted = showMuted
        }
    }
}
