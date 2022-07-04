//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
import AzureCommunicationCalling
@testable import AzureCommunicationUICalling

class OnHoldOverlayViewModelMocking: OnHoldOverlayViewModel {
    var actionButtonViewModelMocking: PrimaryButtonViewModel?
    var resumeAction: (() -> Void)?
    var updateState: ((CallingStatus) -> Void)?

    init(localizationProvider: LocalizationProviderProtocol,
         compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         accessibilityProvider: AccessibilityProviderProtocol,
         resumeAction:  @escaping (() -> Void),
         updateState: ((CallingStatus) -> Void)? = nil) {
        self.resumeAction = resumeAction
        self.updateState = updateState
        self.actionButtonViewModelMocking = PrimaryButtonViewModel(buttonStyle: .primaryFilled,
                                                            buttonLabel: localizationProvider.getLocalizedString(.resume),
                                                            iconName: nil,
                                                            isDisabled: false) {
            resumeAction()
        }
        super.init(localizationProvider: localizationProvider,
                   compositeViewModelFactory: compositeViewModelFactory,
                   logger: logger,
                   accessibilityProvider: accessibilityProvider,
                   resumeAction: resumeAction)
    }

    override func update(callingStatus: CallingStatus,
                         audioSessionStatus: AudioSessionStatus) {
        updateState?(callingStatus)
    }

    func mockResumeAction() {
        self.resumeAction?()
    }
}
