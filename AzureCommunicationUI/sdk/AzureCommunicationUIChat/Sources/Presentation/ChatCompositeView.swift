//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// The Chat Composite View is a view component for a single chat thread
public struct ChatCompositeView: View {

    let chatAdapter: ChatAdapter

    let router: NavigationRouter
    let logger: Logger
    let viewFactory: CompositeViewFactoryProtocol
    let isRightToLeft: Bool

    /// Create an instance of ChatCompositeView with chatAdapter for a single chat thread
    /// - Parameters:
    ///    - chatAdapter: The required parameter to create a view component
    public init(with chatAdapter: ChatAdapter) {
        self.chatAdapter = chatAdapter

        self.router = self.chatAdapter.navigationRouter!
        self.logger = self.chatAdapter.logger
        self.viewFactory = self.chatAdapter.compositeViewFactory!

        let localizationProvider = self.chatAdapter.localizationProvider
        self.isRightToLeft = localizationProvider.isRightToLeft

    }

    /// The view body would be used to render the ChatCompositeView
    public var body: some View {
        VStack {
            ContainerView(router: self.router,
                          logger: self.logger,
                          viewFactory: self.viewFactory,
                          isRightToLeft: self.isRightToLeft)
        }

    }
}
