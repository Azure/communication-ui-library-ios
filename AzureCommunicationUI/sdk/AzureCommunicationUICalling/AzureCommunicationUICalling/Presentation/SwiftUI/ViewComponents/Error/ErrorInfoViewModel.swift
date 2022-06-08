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
    private var previousError: CallCompositeInternalError?

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
        let error = errorState.error
        guard error != previousError else {
            return
        }

        previousError = error
        guard let error = error else {
            isDisplayed = false
            return
        }

        isDisplayed = true
        switch error {
        case .callJoinFailed:
            title = localizationProvider.getLocalizedString(.snackBarErrorJoinCall)
        case .callEndFailed:
            title = localizationProvider.getLocalizedString(.snackBarErrorCallEnd)
        case .callEvicted:
            title = localizationProvider.getLocalizedString(.snackBarErrorCallEvicted)
        case .callDenied:
            title = localizationProvider.getLocalizedString(.snackBarErrorCallDenied)
        default:
            title = localizationProvider.getLocalizedString(.snackBarError)
        }
    }
}
