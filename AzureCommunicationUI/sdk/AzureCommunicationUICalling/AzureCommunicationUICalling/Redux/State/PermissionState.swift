//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum AppPermission {
    case audioPermission
    case cameraPermission

    enum Status: String, Equatable {
        case unknown
        case notAsked
        case requesting
        case granted
        case denied
    }
}

class PermissionState: ReduxState {

    let audioPermission: AppPermission.Status
    let cameraPermission: AppPermission.Status

    init(audioPermission: AppPermission.Status = .unknown, cameraPermission: AppPermission.Status = .unknown) {
        self.audioPermission = audioPermission
        self.cameraPermission = cameraPermission
    }

}
