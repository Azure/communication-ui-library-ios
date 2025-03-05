//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import Combine

/// Observes keyboard notifications and publishes the keyboard height.
final class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0

    private var cancellableSet: Set<AnyCancellable> = []

    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    return frame.height
                }
                return 0
            }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in
                return 0
            }

        Publishers.Merge(willShow, willHide)
            .receive(on: RunLoop.main)
            .assign(to: \.keyboardHeight, on: self)
            .store(in: &cancellableSet)
    }

    deinit {
        cancellableSet.forEach { $0.cancel() }
    }
}
