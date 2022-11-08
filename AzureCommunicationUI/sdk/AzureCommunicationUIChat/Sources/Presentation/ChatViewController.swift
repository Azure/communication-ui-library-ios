//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine
import SwiftUI

public class ChatViewController: UIViewController {
    var chatView: UIHostingController<ContainerView>!

    public init(with chatComposite: ChatComposite) {
        super.init(nibName: nil, bundle: nil)
        let localizationProvider = chatComposite.dependencyContainer.resolve() as LocalizationProviderProtocol

        let containerUIHostingController = chatComposite.makeContainerUIHostingController(
            router: chatComposite.dependencyContainer.resolve(),
            logger: chatComposite.dependencyContainer.resolve(),
            viewFactory: chatComposite.dependencyContainer.resolve(),
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
