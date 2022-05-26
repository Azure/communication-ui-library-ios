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
    private let dispatchAction: ActionDispatch

    private var audioSessionStatus: AudioSessionStatus?

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
         dispatchAction: @escaping ActionDispatch) {
        self.localizationProvider = localizationProvider
        self.compositeViewModelFactory = compositeViewModelFactory
        self.logger = logger
        self.accessibilityProvider = accessibilityProvider
        self.dispatchAction = dispatchAction

        actionButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryFilled,
            buttonLabel: localizationProvider.getLocalizedString(.resume),
            iconName: nil) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Resume from hold button tapped")
                self.resumeButtonTapped()
        }
    }

    func resumeButtonTapped() {
        if audioSessionStatus == .active {
            let action = CallingAction.ResumeRequested()
            dispatchAction(action)
        } else {
            // Display Error Banner
        }
    }

    func update(callingStatus: CallingStatus,
                audioSessionStatus: AudioSessionStatus) {
//        actionButtonViewModel?.isDisabled = audioSessionState.status == .interrupted

        let shouldDisplay = callingStatus == .localHold
        if isDisplayed != shouldDisplay {
            isDisplayed = shouldDisplay
            accessibilityProvider.moveFocusToFirstElement()
        }

        self.audioSessionStatus = audioSessionStatus
    }
}
