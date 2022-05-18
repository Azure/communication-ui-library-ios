//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

struct PermissionAction {
    struct AudioPermissionRequested: Action {}
    struct AudioPermissionGranted: Action {}
    struct AudioPermissionDenied: Action {}
    struct AudioPermissionNotAsked: Action {}

    struct CameraPermissionRequested: Action {}
    struct CameraPermissionGranted: Action {}
    struct CameraPermissionDenied: Action {}
    struct CameraPermissionNotAsked: Action {}

    static func generateAction(permission: AppPermission, state: AppPermission.Status) -> Action {
        switch permission {
        case .audioPermission:
            switch state {
            case .granted:
                return AudioPermissionGranted()
            case .denied:
                return AudioPermissionDenied()
            case .notAsked:
                return AudioPermissionNotAsked()
            default:
                return AudioPermissionDenied()
            }
        case .cameraPermission:
            switch state {
            case .granted:
                return CameraPermissionGranted()
            case .denied:
                return CameraPermissionDenied()
            case .notAsked:
                return CameraPermissionNotAsked()
            default:
                return CameraPermissionDenied()
            }
        }
    }
}
