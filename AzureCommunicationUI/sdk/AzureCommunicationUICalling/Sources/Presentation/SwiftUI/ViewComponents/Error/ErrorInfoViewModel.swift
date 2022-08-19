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
    private var previousErrorType: CallCompositeInternalError?

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
        let errorType = errorState.internalError
        guard errorType != previousErrorType else {
            return
        }

        previousErrorType = errorType
        guard let errorType = errorType else {
            isDisplayed = false
            return
        }

        isDisplayed = true
        switch errorType {
        case .callJoinFailed:
            title = localizationProvider.getLocalizedString(.snackBarErrorJoinCall)
        case .callEndFailed:
            title = localizationProvider.getLocalizedString(.snackBarErrorCallEnd)
        case .callEvicted:
            title = localizationProvider.getLocalizedString(.snackBarErrorCallEvicted)
        case .callDenied:
            title = localizationProvider.getLocalizedString(.snackBarErrorCallDenied)
        case .cameraOnFailed:
            title = localizationProvider.getLocalizedString(.snackBarErrorCameraOnFailed)
        default:
            title = localizationProvider.getLocalizedString(.snackBarError)
        }
    }
}
