//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

class InjectedOverlayState: ObservableObject {
    @Published private(set) var injectedView: AnyView?
    @Published private(set) var injectedViewController: UIViewController?
    @Published private(set) var overlayOptions: OverlayOptions?

    func set(injectedView: AnyView,
             options: OverlayOptions) {
        self.injectedViewController = nil
        self.injectedView = injectedView
        self.overlayOptions = options
    }

    func set(injectedViewController: UIViewController,
             options: OverlayOptions) {
        self.injectedView = nil
        self.injectedViewController = injectedViewController
        self.overlayOptions = options
    }

    func cleanState() {
        self.injectedView = nil
        self.injectedViewController = nil
        self.overlayOptions = nil
    }
}
