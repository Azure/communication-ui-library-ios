//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct InjectedOverlayView: UIViewControllerRepresentable {
    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        let containerVC = UIViewController()
        updateChatHostingVC(containerVC)
        return containerVC
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        updateChatHostingVC(uiViewController)
    }

    private func updateChatHostingVC(_ containerVC: UIViewController) {
        // required step for reusing view of VC
        /*This method creates a parent-child relationship between the current view controller
         and the object in the childController parameter. This relationship is necessary when
         embedding the child view controller’s view into the current view controller’s content.
         If the new child view controller is already the child of a container view controller,
         it is removed from that container before being added.
        https://developer.apple.com/documentation/uikit/uiviewcontroller/1621394-addchild */

        containerVC.addChild(viewController)
        containerVC.view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            viewController.view.bottomAnchor.constraint(equalTo: containerVC.view.bottomAnchor),
            viewController.view.topAnchor.constraint(equalTo: containerVC.view.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: containerVC.view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: containerVC.view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        viewController.didMove(toParent: containerVC)
    }
}
