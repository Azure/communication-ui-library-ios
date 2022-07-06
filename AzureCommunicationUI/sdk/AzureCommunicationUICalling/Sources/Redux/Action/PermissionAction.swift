//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

enum PermissionAction: Equatable {
    case audioPermissionRequested
    case audioPermissionGranted
    case audioPermissionDenied
    case audioPermissionNotAsked

    case cameraPermissionRequested
    case cameraPermissionGranted
    case cameraPermissionDenied
    case cameraPermissionNotAsked

    static func generateAction(permission: AppPermission, state: AppPermission.Status) -> PermissionAction {
        switch permission {
        case .audioPermission:
            switch state {
            case .granted:
                return .audioPermissionGranted
            case .denied:
                return .audioPermissionDenied
            case .notAsked:
                return .audioPermissionNotAsked
            default:
                return .audioPermissionDenied
            }
        case .cameraPermission:
            switch state {
            case .granted:
                return .cameraPermissionGranted
            case .denied:
                return .cameraPermissionDenied
            case .notAsked:
                return .cameraPermissionNotAsked
            default:
                return .cameraPermissionDenied
            }
        }
    }
}
