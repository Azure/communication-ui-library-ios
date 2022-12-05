//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// The Chat Composite View is the entry point for the Chat Composite
public struct ChatCompositeView: View {

    let chatAdapter: ChatAdapter

    let router: NavigationRouter
    let logger: Logger
    let viewFactory: CompositeViewFactoryProtocol
    let isRightToLeft: Bool

    /// Create an instance of ChatCompositeView with chatAdapter
    /// - Parameters:
    ///    - chatAdapter: The required parameter to create composite's view
    public init(with chatAdapter: ChatAdapter) {
        self.chatAdapter = chatAdapter

        self.router = self.chatAdapter.navigationRouter!
        self.logger = self.chatAdapter.logger
        self.viewFactory = self.chatAdapter.compositeViewFactory!

        let localizationProvider = self.chatAdapter.localizationProvider
        self.isRightToLeft = localizationProvider.isRightToLeft

    }

    /// The View's body would be used to render Chat Composite
    public var body: some View {
        VStack {
            ContainerView(router: self.router,
                          logger: self.logger,
                          viewFactory: self.viewFactory,
                          isRightToLeft: self.isRightToLeft)
        }

    }
}
