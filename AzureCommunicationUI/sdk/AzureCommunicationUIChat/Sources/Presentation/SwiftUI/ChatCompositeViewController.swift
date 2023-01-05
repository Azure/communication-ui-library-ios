//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine
import SwiftUI

/// The Chat Composite View Controller is a view component for a single chat thread
public class ChatCompositeViewController: UIViewController {
    var chatView: UIHostingController<ContainerView>!

    /// Create an instance of ChatCompositeViewController with chatAdapter for a single chat thread
    /// - Parameters:
    ///    - chatAdapter: The required parameter to create a view component
    public init(with chatAdapter: ChatAdapter) {
        super.init(nibName: nil, bundle: nil)

        let containerUIHostingController = makeContainerUIHostingController(
            viewFactory: chatAdapter.compositeViewFactory!,
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

    func makeContainerUIHostingController(viewFactory: CompositeViewFactoryProtocol,
                                          canDismiss: Bool) -> ContainerUIHostingController {
        let rootView = ContainerView(viewFactory: viewFactory)
        let containerUIHostingController = ContainerUIHostingController(rootView: rootView)
        containerUIHostingController.modalPresentationStyle = .fullScreen

        return containerUIHostingController
    }
}
