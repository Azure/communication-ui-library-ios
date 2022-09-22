//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ContainerView: View {

    @ObservedObject var router: NavigationRouter

    let logger: Logger
    let viewFactory: CompositeViewFactoryProtocol
    let setupViewOrientationMask: UIInterfaceOrientationMask =
        UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .allButUpsideDown
    let isRightToLeft: Bool

    var body: some View {
        Group {
            switch router.currentView {
            case .chatView:
                chatView.supportedOrientations(setupViewOrientationMask)
                    .accessibilityElement(children: .contain)
                    .accessibilityAddTraits(.isModal)
            }
        }
        .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
    }

    var chatView: ChatView {
        logger.debug("Displaying view: chatView")
        return viewFactory.makeChatView()
    }

}
