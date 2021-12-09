//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

enum AudioDeviceType: String, CaseIterable {
    case receiver = "iOS"
    case speaker = "Speaker"

    var name: String {
        if self == .receiver {
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                return "iPhone"
            case .pad:
                return "iPad"
            default:
                return self.rawValue
            }
        }
        return self.rawValue
    }
}
