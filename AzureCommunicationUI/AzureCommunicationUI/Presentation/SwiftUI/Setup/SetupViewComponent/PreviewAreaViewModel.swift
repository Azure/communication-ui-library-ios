//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class PreviewAreaViewModel: ObservableObject {
    private var cameraPermission: AppPermission.Status = .unknown
    private var audioPermission: AppPermission.Status = .unknown

    @Published var isPermissionsDenied: Bool = false

    let localVideoViewModel: LocalVideoViewModel!
    private let goToSettingsText: String = "To enable, please go to Settings to allow access."
    private let enableAudioToStartText: String = "You must enable audio to start this call."

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
        if self.audioPermission == .granted {
            displayText = "Your camera is disabled. \(goToSettingsText)"
        } else if self.cameraPermission == .denied {
            displayText = "Your camera and audio are disabled. \(goToSettingsText) \(enableAudioToStartText)"
        } else {
            displayText = "Your audio is disabled. \(goToSettingsText) \(enableAudioToStartText)"
        }

        return displayText
    }

    func update(localUserState: LocalUserState, permissionState: PermissionState) {
        self.cameraPermission = permissionState.cameraPermission
        self.audioPermission = permissionState.audioPermission
        updatePermissionsState()
        localVideoViewModel.update(localUserState: localUserState)
    }

    private func updatePermissionsState() {
        let isPermissionDenied = cameraPermission == .denied || audioPermission == .denied
        if isPermissionDenied != self.isPermissionsDenied {
            self.isPermissionsDenied = isPermissionDenied
        }
    }
}
