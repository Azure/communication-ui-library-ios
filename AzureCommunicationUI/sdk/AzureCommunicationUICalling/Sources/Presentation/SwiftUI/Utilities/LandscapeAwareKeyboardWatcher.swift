//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI
import UIKit // Import UIKit to access UIDevice

/*
 Prepares offsets for views impacted by the keyboard, specifically in Landscape mode
 */
class LandscapeAwareKeyboardWatcher: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var keyboardShowObserver: NSObjectProtocol?
    private var keyboardHideObserver: NSObjectProtocol?

    init() {
        self.listenForKeyboardNotifications()
    }

    deinit {
        if let keyboardShowObserver = keyboardShowObserver {
            NotificationCenter.default.removeObserver(keyboardShowObserver)
        }

        if let keyboardHideObserver = keyboardHideObserver {
            NotificationCenter.default.removeObserver(keyboardHideObserver)
        }
    }

    private func listenForKeyboardNotifications() {
        keyboardShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification,
                                                                      object: nil,
                                                                      queue: .main) { [weak self] (notification) in
            guard let self = self else {
                return
            }
            guard let userInfo = notification.userInfo,
                  let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

            if self.isLandscape() {
                self.keyboardHeight = keyboardRect.height
            }
        }

        keyboardHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification,
                                                                      object: nil,
                                                                      queue: .main) { [weak self] _ in
            self?.keyboardHeight = 0
        }
    }

    private func isLandscape() -> Bool {
        // Checking orientation based on status bar orientation to handle orientation lock scenarios
        let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        return orientation == .landscapeLeft || orientation == .landscapeRight
    }
}
