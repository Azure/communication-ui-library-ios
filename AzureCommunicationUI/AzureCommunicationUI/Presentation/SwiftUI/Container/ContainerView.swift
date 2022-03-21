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
                    .accessibilityElement(children: .contain)
                    .accessibility(addTraits: .isModal)
            case .callingView:
                callingView.proximitySensorEnabled(true)
                    .accessibilityElement(children: .contain)
                    .accessibility(addTraits: .isModal)
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
