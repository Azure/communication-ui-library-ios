//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class LobbyOverlayViewModel: OverlayViewModelProtocol {
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol

    init(localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol) {
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
    }

    var title: String {
        return localizationProvider.getLocalizedString(.waitingForHost)
    }

    var subtitle: String? {
        return localizationProvider.getLocalizedString(.waitingDetails)
    }

    @Published var isDisplayed: Bool = false

    func update(callingStatus: CallingStatus) {
        let shouldDisplay = callingStatus == .inLobby
        if shouldDisplay != isDisplayed {
            isDisplayed = shouldDisplay
            accessibilityProvider.moveFocusToFirstElement()
        }
    }
}
