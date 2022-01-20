//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct LockPhoneOrientation: ViewModifier {
    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType

    func body(content: Content) -> some View {
        content
            .supportedOrientations(orientationMask)
    }

    var orientationMask: UIInterfaceOrientationMask {
        switch screenSizeClass {
        case .iphonePortraitScreenSize:
            return .portrait
        case .iphoneLandscapeScreenSize:
            return UIDevice.current.orientation == .landscapeLeft ? .landscapeRight : .landscapeLeft
        default:
            return SupportedOrientationsPreferenceKey.defaultValue
        }
    }
}
