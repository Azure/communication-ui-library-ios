//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ErrorInfoViewModel: ObservableObject {
    @Published var isDisplayed: Bool = false
    @Published var message: String = ""

    private let localizationProvider: LocalizationProvider
    private var previousErrorType: String = ""

    init(with localizationProvider: LocalizationProvider) {
        self.localizationProvider = localizationProvider
    }

    var dismissContent: String {
        return localizationProvider.getLocalizedString(.snackBarDismiss)
    }

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
            message = localizationProvider.getLocalizedString(.snackBarErrorJoinCall)
        case CallCompositeErrorCode.callEnd:
            message = localizationProvider.getLocalizedString(.snackBarErrorCallEnd)
        default:
            message = localizationProvider.getLocalizedString(.snackBarError)
        }
    }
}
