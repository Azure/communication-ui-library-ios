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
