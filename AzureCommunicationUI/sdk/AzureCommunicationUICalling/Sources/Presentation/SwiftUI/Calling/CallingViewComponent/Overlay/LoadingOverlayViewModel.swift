//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class LoadingOverlayViewModel: OverlayViewModelProtocol {
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol

    init(localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol) {
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
    }

    var title: String {
        return localizationProvider.getLocalizedString(.joiningCall)
    }

    var subtitle: String = ""

    @Published var isDisplayed: Bool = false

    func update(callingState: CallingState) {
        let shouldDisplay = callingState.operationStatus == .bypassRequested
        if shouldDisplay != isDisplayed {
            isDisplayed = shouldDisplay
            accessibilityProvider.moveFocusToFirstElement()
        }
    }
}
