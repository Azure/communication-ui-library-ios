//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class SharingActivityContainerController: UIViewController, DrawerViewControllerProtocol {
    private let activityItems: [Any]
    private let applicationActivities: [UIActivity]?
    private weak var controller: UIActivityViewController?
    private let sourceView: UIView
    private var activityControllerCompletion: (() -> Void)?

    init(activityItems: [Any],
         applicationActivities: [UIActivity]?,
         sourceView: UIView,
         activityControllerCompletion: (() -> Void)? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        self.sourceView = sourceView
        self.activityControllerCompletion = activityControllerCompletion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let activityController = UIActivityViewController(activityItems: self.activityItems,
                                                          applicationActivities: self.applicationActivities)
        activityController.completionWithItemsHandler = { [weak self] activityType, completed, _, _ in
            guard let self = self else {
                return
            }
            let isActivityControllerCancelled = activityType == nil && !completed
            let isDataSuccessfullyShared = activityType != nil && completed
            guard isActivityControllerCancelled || isDataSuccessfullyShared else {
                return
            }
            // the controller and overlay can be dismissed
            self.dismissPresentedController()
            self.activityControllerCompletion?()
        }
        activityController.modalPresentationStyle = .popover
            guard let topViewController = UIWindow.keyWindow?.topViewController,
                  let topView = topViewController.view else {
                return
            }
            if !topView.subviews.contains(self.sourceView) {
                self.sourceView.isHidden = true
                topView.isUserInteractionEnabled = false
                topView.addSubview(self.sourceView)
            }
        activityController.popoverPresentationController?.sourceView = self.sourceView
            topViewController.present(activityController, animated: true)
            self.controller = activityController
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed || isMovingFromParent {
            sourceView.superview?.isUserInteractionEnabled = true
            sourceView.removeFromSuperview()
        }
        resetOrientation()
    }

    func dismissPresentedController() {
        controller?.dismiss(animated: false)
        controller = nil
    }
}
