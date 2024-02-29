//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import SwiftUI
import UIKit

class LandscapeAwareKeyboardWatcher: ObservableObject {
<<<<<<< Updated upstream
=======
    static let shared = LandscapeAwareKeyboardWatcher()

>>>>>>> Stashed changes
    @Published var activeHeight: CGFloat = 0

    private var keyboardHeight: CGFloat = 0
    private var isLandscape: Bool = false {
        didSet {
            updateActiveHeight()
        }
    }

    private var keyboardShowObserver: NSObjectProtocol?
    private var keyboardHideObserver: NSObjectProtocol?
    private var orientationChangeObserver: NSObjectProtocol?

    init() {
        listenForKeyboardNotifications()
        listenForOrientationChanges()
        updateOrientationStatus()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if let keyboardShowObserver = keyboardShowObserver {
            NotificationCenter.default.removeObserver(keyboardShowObserver)
        }

        if let keyboardHideObserver = keyboardHideObserver {
            NotificationCenter.default.removeObserver(keyboardHideObserver)
        }

        if let orientationChangeObserver = orientationChangeObserver {
            NotificationCenter.default.removeObserver(orientationChangeObserver)
        }
    }

    private func listenForKeyboardNotifications() {
        keyboardShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification,
                                                                      object: nil,
                                                                      queue: .main) { [weak self] (notification) in
            guard let self = self, let userInfo = notification.userInfo,
                  let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

            self.keyboardHeight = keyboardRect.height
            self.updateActiveHeight()
        }

        keyboardHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification,
                                                                      object: nil,
                                                                      queue: .main) { [weak self] _ in
            self?.keyboardHeight = 0
            self?.updateActiveHeight()
        }
    }

    private func listenForOrientationChanges() {
        orientationChangeObserver = NotificationCenter
            .default
            .addObserver(forName: UIDevice.orientationDidChangeNotification,
                         object: nil,
                         queue: .main) { [weak self] _ in
                self?.updateOrientationStatus()
            }
    }

    private func updateOrientationStatus() {
        let currentOrientation = UIDevice.current.orientation
        isLandscape = currentOrientation == .landscapeLeft || currentOrientation == .landscapeRight
<<<<<<< Updated upstream
=======

>>>>>>> Stashed changes
    }

    private func updateActiveHeight() {
        activeHeight = isLandscape ? keyboardHeight : 0
    }
}
