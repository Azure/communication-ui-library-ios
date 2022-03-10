//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true:
            self.hidden()
        case false:
            self
        }
    }

    func supportedOrientations(_ supportedOrientations: UIInterfaceOrientationMask) -> some View {
        // When rendered, export the requested orientations upward to Root
        preference(key: SupportedOrientationsPreferenceKey.self, value: supportedOrientations)
    }

    func proximitySensorEnabled(_ proximityEnabled: Bool) -> some View {
        preference(key: ProximitySensorPreferenceKey.self, value: proximityEnabled)
    }
}
