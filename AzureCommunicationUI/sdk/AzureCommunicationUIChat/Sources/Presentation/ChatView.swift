//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

public struct ChatView: View {

    let chatComposite: ChatComposite

    let router: NavigationRouter
    let logger: Logger
    let viewFactory: CompositeViewFactoryProtocol
    let isRightToLeft: Bool

    public init(with chatComposite: ChatComposite) {
        self.chatComposite = chatComposite

        self.router = self.chatComposite.dependencyContainer!.resolve()
        self.logger = self.chatComposite.dependencyContainer!.resolve()
        self.viewFactory = self.chatComposite.dependencyContainer!.resolve()

        let localizationProvider: LocalizationProviderProtocol = self.chatComposite.dependencyContainer!.resolve()
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
