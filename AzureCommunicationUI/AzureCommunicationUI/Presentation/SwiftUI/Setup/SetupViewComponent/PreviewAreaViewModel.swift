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
    private let localizationProvider: LocalizationProvider

    init(compositeViewModelFactory: CompositeViewModelFactory,
         dispatchAction: @escaping ActionDispatch,
         localizationProvider: LocalizationProvider) {
        localVideoViewModel = compositeViewModelFactory.makeLocalVideoViewModel(dispatchAction: dispatchAction)
        self.localizationProvider = localizationProvider
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
            displayText = localizationProvider.getLocalizedString(.cameraDisabled)
        } else if self.cameraPermission == .denied {
            displayText = localizationProvider.getLocalizedString(.audioAndCameraDisabled)
        } else {
            displayText = localizationProvider.getLocalizedString(.audioDisabled)
        }
        return displayText
    }

    func showPermissionWarning() -> Bool {
        self.cameraPermission == .denied || self.audioPermission == .denied
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
