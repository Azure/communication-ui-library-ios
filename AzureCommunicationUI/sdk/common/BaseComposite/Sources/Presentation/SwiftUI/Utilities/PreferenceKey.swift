//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct SupportedOrientationsPreferenceKey: PreferenceKey {
    static var defaultValue: UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown
    }

    static func reduce(value: inout UIInterfaceOrientationMask, nextValue: () -> UIInterfaceOrientationMask) {
        // Use the most restrictive set from the stack
        value.formIntersection(nextValue())
    }
}

struct ProximitySensorPreferenceKey: PreferenceKey {
    static var defaultValue: Bool {
        return false
    }

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

struct PrefersHomeIndicatorAutoHiddenPreferenceKey: PreferenceKey {

    static var defaultValue: Bool {
        return false
    }

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue() || value
    }
}
