//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ContainerView: View {

    @ObservedObject var router: NavigationRouter

    let logger: Logger
    let viewFactory: CompositeViewFactoryProtocol
    let setupViewDefaultOrientation: UIInterfaceOrientationMask =
    UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .allButUpsideDown
    let setupViewOrientationMask: UIInterfaceOrientationMask?
    let callingViewOrientationMask: UIInterfaceOrientationMask?
    let isRightToLeft: Bool
    var isCallingScreenLocked: Bool {
        return !(callingViewOrientationMask  == .allButUpsideDown || callingViewOrientationMask == nil)
    }

    var body: some View {
        Group {
            contentView
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
        .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
    }

    @ViewBuilder
    private var contentView: some View {
        switch router.currentView {
        case .setupView:
            setupView.supportedOrientations(setupViewOrientationMask ?? setupViewDefaultOrientation)
        case .callingView:
            if isCallingScreenLocked {
                callingView.proximitySensorEnabled(true)
                    .supportedOrientations(callingViewOrientationMask ?? .portrait)
            } else {
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
