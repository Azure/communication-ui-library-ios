//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class SharingActivityContainerController: UIViewController, DrawerViewControllerProtocol {
    private let viewModel: DiagnosticsSharingActivityViewModel
    private let applicationActivities: [UIActivity]?
    private weak var controller: UIActivityViewController?
    private let sourceView: UIView
    private var activityControllerCompletion: (() -> Void)?

    init(viewModel: DiagnosticsSharingActivityViewModel,
         applicationActivities: [UIActivity]?,
         sourceView: UIView,
         activityControllerCompletion: (() -> Void)? = nil) {
        self.viewModel = viewModel
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
        guard let topViewController = UIWindow.keyWindow?.topViewController,
              let topView = topViewController.view else {
            return
        }
        if !topView.subviews.contains(sourceView) {
            self.sourceView.isHidden = true
            topView.isUserInteractionEnabled = false
            topView.addSubview(sourceView)
        }
        let activityController = UIActivityViewController(activityItems: [viewModel.getDiagnosticsInfo()],
                                                          applicationActivities: applicationActivities)
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
        activityController.popoverPresentationController?.sourceView = sourceView
        activityController.accessibilityViewIsModal = true
        controller = activityController
        topViewController.present(activityController, animated: true) { [weak self] in
            // Copy Apple's Share behaviour
            guard let controller = self?.controller else {
                return
            }

            self?.viewModel.accessibilityProvider.moveFocusToView(controller.view)
        }
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
