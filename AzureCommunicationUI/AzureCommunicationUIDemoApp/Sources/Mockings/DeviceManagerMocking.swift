//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

class DeviceManagerMocking {
    weak var delegate: DeviceManagerDelegate?
    var cameras: [VideoDeviceInfoMocking] = []
    init() {
        cameras = [VideoDeviceInfoMocking(cameraFacing: .front),
                   VideoDeviceInfoMocking(cameraFacing: .back)]
    }
}
