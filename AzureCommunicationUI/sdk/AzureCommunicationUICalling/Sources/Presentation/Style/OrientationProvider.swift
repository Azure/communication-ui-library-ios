//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

class OrientationProvider {
    private let orientationOptions: OrientationOptions

    init(orientationOptions: OrientationOptions) {
        self.orientationOptions = orientationOptions
    }

    func orientationMask(for options: OrientationOptions) -> UIInterfaceOrientationMask {
        switch options.requestString {
        case "portrait":
            return .portrait
        case "landscape":
            return .landscape
        case "all" :
            return .all
        default:
            return .portrait
        }
    }
}
