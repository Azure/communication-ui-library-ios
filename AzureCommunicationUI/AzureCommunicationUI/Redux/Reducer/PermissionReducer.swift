//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct PermissionReducer: Reducer {
    func reduce(_ state: ReduxState, _ action: Action) -> ReduxState {
        guard let permissionState = state as? PermissionState else {
            return state
        }
        var cameraPermission = permissionState.cameraPermission
        var audioPermission = permissionState.audioPermission
        switch action {
        case _ as PermissionAction.AudioPermissionRequested:
            audioPermission = .requesting
        case _ as PermissionAction.AudioPermissionGranted:
            audioPermission = .granted
        case _ as PermissionAction.AudioPermissionDenied:
            audioPermission = .denied
        case _ as PermissionAction.AudioPermissionNotAsked:
            audioPermission = .notAsked
        case _ as PermissionAction.CameraPermissionRequested:
            cameraPermission = .requesting
        case _ as PermissionAction.CameraPermissionGranted:
            cameraPermission = .granted
        case _ as PermissionAction.CameraPermissionDenied:
            cameraPermission = .denied
        case _ as PermissionAction.CameraPermissionNotAsked:
            cameraPermission = .notAsked
        default:
            return permissionState
        }
        return PermissionState(audioPermission: audioPermission,
                               cameraPermission: cameraPermission)
    }
}
