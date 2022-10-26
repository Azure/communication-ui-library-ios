//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI

struct SharingActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?
    @Binding var isPresented: Bool
    let sourceView: UIView

    func makeUIViewController(context: Context) -> NewActiVC {
//        let activityController = UIActivityViewController(activityItems: activityItems,
//                                                          applicationActivities: applicationActivities)
//        activityController.completionWithItemsHandler = { _, _, _, _ in
//            print("!!!! completion!")
//        }
//        return activityController
        return NewActiVC(activityItems: activityItems,
                         applicationActivities: applicationActivities,
                         sourceView: sourceView,
                         isPresented: $isPresented)
    }

    func updateUIViewController(_ uiViewController: NewActiVC, context: Context) {}

    static func dismantleUIViewController(_ controller: NewActiVC,
                                          coordinator: Coordinator) {
        controller.dismissPresentedController()
    }
}

class NewActiVC: UIViewController {
    @Binding var isPresented: Bool
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?
    weak var controller: UIActivityViewController?
    private let sourceView: UIView

    init(activityItems: [Any],
         applicationActivities: [UIActivity]?,
         sourceView: UIView,
         isPresented: Binding<Bool>) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        self.sourceView = sourceView
        self._isPresented = isPresented
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            print("!!!! viewDidLoad")
            let activityController = UIActivityViewController(activityItems: self.activityItems,
                                                              applicationActivities: self.applicationActivities)
            activityController.completionWithItemsHandler = { _, _, _, _ in
                self.dismissPresentedController()
                self.isPresented = false
            }
            activityController.modalPresentationStyle = .popover

            DispatchQueue.main.async {
                activityController.popoverPresentationController?.sourceView = self.sourceView
                guard let topViewController = UIWindow.keyWindow?.topViewController,
                      let topView = topViewController.view else {
                    return
                }

                if !topView.subviews.contains(self.sourceView) {
                    self.sourceView.isHidden = true
                    topView.isUserInteractionEnabled = false
                    topView.addSubview(self.sourceView)
                }

                topViewController.present(activityController, animated: true)
                self.controller = activityController
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("!!!! viewDidDisappear")
        if isBeingDismissed || isMovingFromParent {
            sourceView.superview?.isUserInteractionEnabled = true
            sourceView.removeFromSuperview()
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            UIDevice.current.setValue(UIDevice.current.orientation.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

    func dismissPresentedController() {
        controller?.dismiss(animated: false)
    }
}
