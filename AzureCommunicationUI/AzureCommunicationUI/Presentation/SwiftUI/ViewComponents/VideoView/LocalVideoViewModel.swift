//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class LocalVideoViewModel: ObservableObject {
    private let logger: Logger
    @Published var localVideoStreamId: String?
    @Published var displayName: String?
    @Published var isMuted: Bool = false

    var cameraSwitchButtonPipViewModel: IconButtonViewModel!
    var cameraSwitchButtonFullViewModel: IconButtonViewModel!

    private let dispatch: ActionDispatch

    init(compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         dispatchAction: @escaping ActionDispatch) {
        self.dispatch = dispatchAction
        self.logger = logger
        self.cameraSwitchButtonPipViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .cameraSwitch,
            buttonType: .cameraSwitchButtonPip,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.toggleCameraSwitchTapped()
        }
        self.cameraSwitchButtonFullViewModel = compositeViewModelFactory.makeIconButtonViewModel(
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
        let action = LocalUserAction.CameraSwitchTriggered()
        dispatch(action)
    }

    func update(localUserState: LocalUserState) {
        if localVideoStreamId != localUserState.localVideoStreamIdentifier {
            localVideoStreamId = localUserState.localVideoStreamIdentifier
        }

        if displayName != localUserState.displayName {
            displayName = localUserState.displayName
        }

        self.cameraSwitchButtonPipViewModel.update(isDisabled: localUserState.cameraState.device == .switching)
        self.cameraSwitchButtonPipViewModel.update(accessibilityLabel: localUserState.cameraState.device.label)

        self.cameraSwitchButtonFullViewModel.update(isDisabled: localUserState.cameraState.device == .switching)
        self.cameraSwitchButtonFullViewModel.update(accessibilityLabel: localUserState.cameraState.device.label)

        let showMuted = localUserState.audioState.operation != .on
        if self.isMuted != showMuted {
            self.isMuted = showMuted
        }
    }
}
