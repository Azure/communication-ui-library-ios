//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class PreviewAreaViewModel: ObservableObject {
    @Published var cameraStatus: LocalUserState.CameraOperationalStatus = .off
    @Published var cameraPermission: AppPermission.Status = .unknown
    @Published var audioPermission: AppPermission.Status = .unknown

    let localVideoViewModel: LocalVideoViewModel!

    init(compositeViewModelFactory: CompositeViewModelFactory,
         dispatchAction: @escaping ActionDispatch) {
        localVideoViewModel = compositeViewModelFactory.makeLocalVideoViewModel(dispatchAction: dispatchAction)
    }

    func getPermissionWarningIcon() -> CompositeIcon {
        let displayIcon: CompositeIcon

        if self.audioPermission == .granted {
            displayIcon = .videoOff
        } else if self.cameraPermission == .denied {
            displayIcon = .warning
        } else {
            displayIcon = .micOff
        }

        return displayIcon
    }

    func getPermissionWarningText() -> String {
        let displayText: String
        let goToSettingsText = "To enable, please go to Settings to allow access."
        let enableAudioToStartText = "You must enable audio to start this call."

        if self.audioPermission == .granted {
            displayText = "Your camera is disabled. \(goToSettingsText)"
        } else if self.cameraPermission == .denied {
            displayText = "Your camera and audio are disabled. \(goToSettingsText) \(enableAudioToStartText)"
        } else {
            displayText = "Your audio is disabled. \(goToSettingsText) \(enableAudioToStartText)"
        }

        return displayText
    }

    func showPermissionWarning() -> Bool {
        self.cameraPermission == .denied || self.audioPermission == .denied
    }

    func isCameraOn() -> Bool {
        self.cameraStatus == .on
    }

    func update(localUserState: LocalUserState, permissionState: PermissionState) {
        if self.cameraStatus != localUserState.cameraState.operation {
            self.cameraStatus = localUserState.cameraState.operation
        }
        if self.cameraPermission != permissionState.cameraPermission {
            self.cameraPermission = permissionState.cameraPermission
        }
        if self.audioPermission != permissionState.audioPermission {
            self.audioPermission = permissionState.audioPermission
        }
        localVideoViewModel.update(localUserState: localUserState)
    }
}
