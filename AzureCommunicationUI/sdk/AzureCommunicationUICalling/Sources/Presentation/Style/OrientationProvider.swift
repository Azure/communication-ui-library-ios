//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

class OrientationProvider {
    func orientationMask(for options: OrientationOptions?) -> UIInterfaceOrientationMask? {
        switch options?.requestString {
        case "portrait":
            return .portrait
        case "landscape":
            return .landscape
        case "allButUpsideDown" :
            return .allButUpsideDown
        case "landscapeRight":
            return .landscapeRight
        case "landscapeLeft":
            return .landscapeLeft
        default:
            return nil
        }
    }
}
