//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ContainerView: View {

    @ObservedObject var router: NavigationRouter

    let logger: Logger
    let viewFactory: CompositeViewFactory
    let setupViewOrientationMask: UIInterfaceOrientationMask = .portrait

    var body: some View {
        Group {
            switch router.currentView {
            case .setupView:
                setupView.supportedOrientations(setupViewOrientationMask)
            case .callingView:
                callingView.proximitySensorEnabled(true)
            }
        }
    }

    var setupView: SetupView {
        logger.debug("Displaying view: setupView")
        return viewFactory.makeSetupView()
    }

    var callingView: CallingView {
        logger.debug("Displaying view: callingView")
        return viewFactory.makeCallingView()
    }
}
