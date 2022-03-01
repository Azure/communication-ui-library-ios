//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI

class DrawerContainerViewController<T>: UIViewController, DrawerControllerDelegate {
    var items: [T] = []
    let sourceView: UIView

    var drawerController: DrawerController? {
        return nil
    }

    weak var delegate: DrawerControllerDelegate?

    init(items: [T], sourceView: UIView) {
        self.items = items
        self.sourceView = sourceView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        showDrawerView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed || isMovingFromParent {
            sourceView.superview?.isUserInteractionEnabled = true
            sourceView.removeFromSuperview()
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIDevice.current.setValue(UIDevice.current.orientation.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

    func dismissDrawer(animated: Bool = false) {
        drawerController?.dismiss(animated: animated)
    }

    func showDrawerView() {
        DispatchQueue.main.async {
            guard let topViewController = UIWindow.keyWindow?.topViewController,
                  let topView = topViewController.view else {
                return
            }

            if !topView.subviews.contains(self.sourceView) {
                self.sourceView.isHidden = true
                topView.isUserInteractionEnabled = false
                topView.addSubview(self.sourceView)
            }

            if let drawerController = self.getDrawerController(from: self.sourceView) {
                topViewController.present(drawerController, animated: true, completion: nil)
            }
        }
    }

    func updateDrawerList(items: [T]) {
        self.items = items
    }

    func getDrawerController(from sourceView: UIView) -> DrawerController? {
        return nil
    }
}
