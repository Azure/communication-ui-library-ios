//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

class OnHoldOverlayViewModel: OverlayViewModelProtocol, ObservableObject {
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let logger: Logger
    private let accessibilityProvider: AccessibilityProviderProtocol
    private var audioSessionStatus: AudioSessionStatus = .interrupted
    private var resumeAction: (() -> Void)

    var title: String {
        return localizationProvider.getLocalizedString(.onHoldMessage)
    }

    var background: UIColor {
        return StyleProvider.color.onHoldBackground
    }

    var errorInfoViewModel: ErrorInfoViewModel?

    @Published var actionButtonViewModel: PrimaryButtonViewModel?

    @Published var isDisplayed: Bool = false

    init(localizationProvider: LocalizationProviderProtocol,
         compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         accessibilityProvider: AccessibilityProviderProtocol,
         resumeAction: @escaping (() -> Void)) {
        self.localizationProvider = localizationProvider
        self.compositeViewModelFactory = compositeViewModelFactory
        self.logger = logger
        self.accessibilityProvider = accessibilityProvider
        let errorInfoTitle = localizationProvider.getLocalizedString(.snackBarErrorOnHoldTitle)
        let errorInfoSubtitle = localizationProvider.getLocalizedString(.snackBarErrorOnHoldSubtitle)
        self.errorInfoViewModel = compositeViewModelFactory.makeErrorInfoViewModel(title: errorInfoTitle,
                                                                            subtitle: errorInfoSubtitle)
        self.resumeAction = resumeAction
        self.actionButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryFilled,
            buttonLabel: localizationProvider.getLocalizedString(.resume),
            iconName: nil,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.logger.debug("Resume from hold button tapped")
                if self.audioSessionStatus == .active {
                    resumeAction()
                } else {
                    self.errorInfoViewModel?.show()
                }
        }
        self.actionButtonViewModel?
            .update(accessibilityLabel: AccessibilityIdentifier.callResumeAccessibilityID.rawValue)
    }

    func update(callingStatus: CallingStatus,
                audioSessionStatus: AudioSessionStatus) {
        self.audioSessionStatus = audioSessionStatus
        let shouldDisplay = callingStatus == .localHold
        if isDisplayed != shouldDisplay {
            isDisplayed = shouldDisplay
            accessibilityProvider.moveFocusToFirstElement()
        }

        if !isDisplayed {
            self.errorInfoViewModel?.dismiss()
        }
    }
}
