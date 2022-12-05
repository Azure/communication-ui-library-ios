//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

public struct ChatThreadView: View {

    let chatAdapter: ChatThreadAdapter

    let router: NavigationRouter
    let logger: Logger
    let viewFactory: CompositeViewFactoryProtocol
    let isRightToLeft: Bool

    public init(with chatAdapter: ChatThreadAdapter) {
        self.chatAdapter = chatAdapter

        self.router = self.chatAdapter.client.navigationRouter!
        self.logger = self.chatAdapter.client.logger
        self.viewFactory = self.chatAdapter.client.compositeViewFactory!

        let localizationProvider = self.chatAdapter.client.localizationProvider
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
