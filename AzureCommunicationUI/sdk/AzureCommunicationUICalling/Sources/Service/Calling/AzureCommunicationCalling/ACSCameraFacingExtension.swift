//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCommunicationCalling
import Foundation

extension CameraFacing {
    func toCameraDevice() -> CameraDevice {
        switch self {
        case .front:
            return .front
        case .back:
            return .back
        default:
            return .front
        }
    }
}
