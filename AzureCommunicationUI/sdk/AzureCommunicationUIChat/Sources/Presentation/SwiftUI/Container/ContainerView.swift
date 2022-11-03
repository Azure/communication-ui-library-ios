//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ContainerView: View {

    @ObservedObject var router: NavigationRouter

    let logger: Logger
    let viewFactory: CompositeViewFactoryProtocol
    let isRightToLeft: Bool

    var body: some View {
        Group {
            switch router.currentView {
            case .chatView:
                chatView
            }
        }
        .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
        .onAppear { viewFactory.enter(.foreground) }
        .onDisappear { viewFactory.enter(.background) }
    }

    var chatView: ChatView {
        logger.debug("Displaying view: chatView")
        return viewFactory.makeChatView()
    }

}
