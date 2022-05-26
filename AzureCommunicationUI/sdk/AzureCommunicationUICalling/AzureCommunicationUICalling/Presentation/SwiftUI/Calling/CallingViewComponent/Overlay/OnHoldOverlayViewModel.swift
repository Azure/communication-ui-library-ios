//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class OnHoldOverlayViewModel: OverlayViewModelProtocol, ObservableObject {
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactory
    private let logger: Logger
    private let accessibilityProvider: AccessibilityProviderProtocol

    var title: String {
        return localizationProvider.getLocalizedString(.onHoldMessage)
    }

    var subtitle: String?

    @Published var actionButtonViewModel: PrimaryButtonViewModel?

    @Published var isDisplayed: Bool = false

    init(localizationProvider: LocalizationProviderProtocol,
         compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         accessibilityProvider: AccessibilityProviderProtocol,
         resume: @escaping (() -> Void)) {
        self.localizationProvider = localizationProvider
        self.compositeViewModelFactory = compositeViewModelFactory
        self.logger = logger
        self.accessibilityProvider = accessibilityProvider

        actionButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryFilled,
            buttonLabel: localizationProvider.getLocalizedString(.resume),
            iconName: nil) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Resume from hold button tapped")
                resume()
        }
    }

    func update(callingStatus: CallingStatus) {
        let shouldDisplay = callingStatus == .localHold
        if isDisplayed != shouldDisplay {
            isDisplayed = shouldDisplay
            accessibilityProvider.moveFocusToFirstElement()
        }
    }
}
