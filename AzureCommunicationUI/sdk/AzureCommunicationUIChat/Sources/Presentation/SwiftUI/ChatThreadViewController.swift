//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine
import SwiftUI

public class ChatThreadViewController: UIViewController {
    var chatView: UIHostingController<ContainerView>!

    public init(with chatAdapter: ChatThreadAdapter) {
        super.init(nibName: nil, bundle: nil)
        let localizationProvider = chatAdapter.client.localizationProvider

        let containerUIHostingController = chatAdapter.client.makeContainerUIHostingController(
            router: chatAdapter.client.navigationRouter!,
            logger: chatAdapter.client.logger,
            viewFactory: chatAdapter.client.compositeViewFactory!,
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
