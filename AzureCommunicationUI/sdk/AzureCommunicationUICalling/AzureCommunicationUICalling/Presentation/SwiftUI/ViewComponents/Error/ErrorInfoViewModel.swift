//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ErrorInfoViewModel: ObservableObject {
    @Published var isDisplayed: Bool = false
    @Published private(set) var message: String = ""
    @Published private(set) var accessibilityLabel: String = ""
    @Published private(set) var dismissButtonAccessibilityLabel: String = ""
    @Published private(set) var dismissButtonAccessibilityHint: String = ""

    private let localizationProvider: LocalizationProviderProtocol
    private var previousErrorType: String = ""

    init(localizationProvider: LocalizationProviderProtocol) {
        self.localizationProvider = localizationProvider

        dismissButtonAccessibilityLabel = localizationProvider.getLocalizedString(.snackBarDismissAccessibilityLabel)
        dismissButtonAccessibilityHint = localizationProvider.getLocalizedString(.snackBarDismissAccessibilityHint)
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
        case CallCompositeErrorCode.callEvicted:
            message = localizationProvider.getLocalizedString(.snackBarErrorCallEvicted)
        case CallCompositeErrorCode.callDenied:
            message = localizationProvider.getLocalizedString(.snackBarErrorCallDenied)
        default:
            message = localizationProvider.getLocalizedString(.snackBarError)
        }
        accessibilityLabel = message
    }
}
