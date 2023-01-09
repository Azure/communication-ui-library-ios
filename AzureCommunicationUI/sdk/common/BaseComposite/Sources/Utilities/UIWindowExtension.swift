//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

extension UIWindow {

    static var keyWindow: UIWindow? {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    }

    var topViewController: UIViewController? {
        if var topViewController = self.rootViewController {
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }

            return topViewController
        } else {
            return nil
        }
    }

    func hasViewController(ofKind kind: AnyClass) -> Bool {
        if let rootViewController = self.rootViewController {
            return UIWindow.hasViewController(ofKind: kind, fromViewController: rootViewController)
        } else {
            return false
        }
    }

    static func hasViewController(ofKind kind: AnyClass,
                                  fromViewController viewController: UIViewController) -> Bool {
        guard !viewController.isKind(of: kind) else {
            return true
        }

        var hasViewController = false
        if !viewController.children.isEmpty {
            viewController.children.forEach {
                if UIWindow.hasViewController(ofKind: kind, fromViewController: $0) {
                    hasViewController = true
                }
            }
        }

        if let presented = viewController.presentedViewController,
           UIWindow.hasViewController(ofKind: kind, fromViewController: presented) {
            hasViewController = true
        }

        return hasViewController
    }

}
