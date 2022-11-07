//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine
import SwiftUI

public class ChatUIKitViewController: UIViewController {

    private var chatComposite: ChatComposite
    private var dependencyContainer: DependencyContainer
    var chatView: UIHostingController<ContainerView>!

    public init(with chatComposite: ChatComposite) {

        self.chatComposite = chatComposite
        self.dependencyContainer = self.chatComposite.dependencyContainer!
        super.init(nibName: nil, bundle: nil)
        let localizationProvider = self.dependencyContainer.resolve() as LocalizationProviderProtocol

        let containerUIHostingController = self.chatComposite.makeContainerUIHostingController(
            router: self.dependencyContainer.resolve(),
            logger: self.dependencyContainer.resolve(),
            viewFactory: self.dependencyContainer.resolve(),
            isRightToLeft: localizationProvider.isRightToLeft,
            canDismiss: true)

        addChild(containerUIHostingController)
        self.view.addSubview(containerUIHostingController.view)
        containerUIHostingController.view.frame = view.bounds
        containerUIHostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerUIHostingController.didMove(toParent: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
