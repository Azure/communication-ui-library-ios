//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

let livePermissionsReducer = Reducer<PermissionState, PermissionAction> { permissionState, action in

    var cameraPermission = permissionState.cameraPermission
    var audioPermission = permissionState.audioPermission
    switch action {
    case .audioPermissionRequested:
        audioPermission = .requesting
    case .audioPermissionGranted:
        audioPermission = .granted
    case .audioPermissionDenied:
        audioPermission = .denied
    case .audioPermissionNotAsked:
        audioPermission = .notAsked
    case .cameraPermissionRequested:
        cameraPermission = .requesting
    case .cameraPermissionGranted:
        cameraPermission = .granted
    case .cameraPermissionDenied:
        cameraPermission = .denied
    case .cameraPermissionNotAsked:
        cameraPermission = .notAsked
    }
    return PermissionState(audioPermission: audioPermission,
                           cameraPermission: cameraPermission)
}
