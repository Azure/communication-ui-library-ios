//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import UIKit

class ErrorInfoViewModel: ObservableObject {
    @Published var isDisplayed: Bool = false
    @Published private(set) var message: String = ""
    @Published private(set) var accessibilityLabel: String = ""
    @Published private(set) var dismissButtonAccessibilityLabel: String = ""
    @Published private(set) var dismissButtonAccessibilityHint: String = ""

    private var previousErrorType: String = ""

    func update(errorState: ErrorState) {
        let errorType = errorState.error?.code ?? ""
        guard errorType != previousErrorType else {
                  return
        }

        previousErrorType = errorState.error?.code ?? ""
        guard !errorType.isEmpty else {
            isDisplayed = false
            return
        }

        isDisplayed = true
        switch errorState.error?.code {
        case CallCompositeErrorCode.callJoin:
            message = "Unable to join the call due to an error."
        case CallCompositeErrorCode.callEnd:
            message = "You were removed from the call due to an error."
        default:
            message = "There was an error."
        }
        accessibilityLabel = message
    }

    func update(dismissButtonAccessibilityLabel: String) {
        if self.dismissButtonAccessibilityLabel != dismissButtonAccessibilityLabel {
            self.dismissButtonAccessibilityLabel = dismissButtonAccessibilityLabel
        }
    }

    func update(dismissButtonAccessibilityHint: String) {
        if self.dismissButtonAccessibilityHint != dismissButtonAccessibilityHint {
            self.dismissButtonAccessibilityHint = dismissButtonAccessibilityHint
        }
    }
}
