//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ErrorInfoViewModel: ObservableObject {
    @Published private(set) var isDisplayed: Bool = false
    @Published private(set) var message: String = ""

    private let localizationProvider: LocalizationProviderProtocol
    private var previousErrorType: String = ""

    init(localizationProvider: LocalizationProviderProtocol) {
        self.localizationProvider = localizationProvider
    }

    var dismissContent: String {
        localizationProvider.getLocalizedString(.snackBarDismiss)
    }
    var dismissAccessibilitylabel: String {
        localizationProvider.getLocalizedString(.snackBarDismissAccessibilityLabel)
    }
    var dismissAccessibilityHint: String {
        localizationProvider.getLocalizedString(.snackBarDismissAccessibilityHint)
    }

    func dismiss() {
        isDisplayed = false
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
        case CallCompositeErrorCode.callEvicted:
            message = localizationProvider.getLocalizedString(.snackBarErrorCallEvicted)
        case CallCompositeErrorCode.callDenied:
            message = localizationProvider.getLocalizedString(.snackBarErrorCallDenied)
        default:
            message = localizationProvider.getLocalizedString(.snackBarError)
        }
    }
}
