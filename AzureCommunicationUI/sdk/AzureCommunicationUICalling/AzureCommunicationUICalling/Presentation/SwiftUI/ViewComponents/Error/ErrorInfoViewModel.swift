//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ErrorInfoViewModel: ObservableObject {
    @Published private(set) var isDisplayed: Bool = false
    @Published private(set) var title: String
    @Published private(set) var subtitle: String

    private let localizationProvider: LocalizationProviderProtocol
    private var previousErrorType: String = ""

    init(localizationProvider: LocalizationProviderProtocol,
         title: String = "",
         subtitle: String = "") {
        self.localizationProvider = localizationProvider
        self.title = title
        self.subtitle = subtitle
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

    func show() {
        isDisplayed = true
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
            title = localizationProvider.getLocalizedString(.snackBarErrorJoinCall)
        case CallCompositeErrorCode.callEnd:
            title = localizationProvider.getLocalizedString(.snackBarErrorCallEnd)
        case CallCompositeErrorCode.callEvicted:
            title = localizationProvider.getLocalizedString(.snackBarErrorCallEvicted)
        case CallCompositeErrorCode.callDenied:
            title = localizationProvider.getLocalizedString(.snackBarErrorCallDenied)
        default:
            title = localizationProvider.getLocalizedString(.snackBarError)
        }
    }
}
