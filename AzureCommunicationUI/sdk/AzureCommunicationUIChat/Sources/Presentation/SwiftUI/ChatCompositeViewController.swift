//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine
import SwiftUI

public class ChatCompositeViewController: UIViewController {
    var chatView: UIHostingController<ContainerView>!

    public init(with chatAdapter: ChatAdapter) {
        super.init(nibName: nil, bundle: nil)
        let localizationProvider = chatAdapter.dependencyContainer!.resolve() as LocalizationProviderProtocol

        let containerUIHostingController = chatAdapter.makeContainerUIHostingController(
            router: chatAdapter.dependencyContainer!.resolve(),
            logger: chatAdapter.dependencyContainer!.resolve(),
            viewFactory: chatAdapter.dependencyContainer!.resolve(),
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
