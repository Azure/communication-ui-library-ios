//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

public struct ChatCompositeView: View {

    let chatAdapter: ChatAdapter

    let router: NavigationRouter
    let logger: Logger
    let viewFactory: CompositeViewFactoryProtocol
    let isRightToLeft: Bool

    public init(with chatAdapter: ChatAdapter) {
        self.chatAdapter = chatAdapter

        self.router = self.chatAdapter.navigationRouter!
        self.logger = self.chatAdapter.logger
        self.viewFactory = self.chatAdapter.compositeViewFactory!

        let localizationProvider = self.chatAdapter.localizationProvider
        self.isRightToLeft = localizationProvider.isRightToLeft

    }

    public var body: some View {
        VStack {
            ContainerView(router: self.router,
                          logger: self.logger,
                          viewFactory: self.viewFactory,
                          isRightToLeft: self.isRightToLeft)
        }

    }
}
