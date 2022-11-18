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

        self.router = self.chatAdapter.dependencyContainer!.resolve()
        self.logger = self.chatAdapter.dependencyContainer!.resolve()
        self.viewFactory = self.chatAdapter.dependencyContainer!.resolve()

        let localizationProvider: LocalizationProviderProtocol = self.chatAdapter.dependencyContainer!.resolve()
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
