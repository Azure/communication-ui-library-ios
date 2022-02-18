//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ErrorInfoViewModel: ObservableObject {
    @Published var isDisplayed: Bool = false
    @Published var message: String = ""

    private var previousErrorType: String = ""

    func update(errorState: ErrorState) {
        guard errorState.error?.code != "",
              errorState.error?.code != previousErrorType else {
                  return
              }

        isDisplayed = true
        previousErrorType = errorState.error?.code ?? ""
        switch errorState.error?.code {
        case CallCompositeErrorCode.callJoin:
            message = "Unable to join the call due to an error."
        case CallCompositeErrorCode.callEnd:
            message = "You were removed from the call due to an error."
        default:
            message = "There was an error."
        }
    }
}
