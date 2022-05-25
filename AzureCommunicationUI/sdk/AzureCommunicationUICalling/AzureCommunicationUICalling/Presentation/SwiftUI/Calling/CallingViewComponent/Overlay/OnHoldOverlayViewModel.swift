//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class OnHoldOverlayViewModel: OverlayViewModelProtocol, ObservableObject {
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactory
    private let logger: Logger
    private let actionDispatch: ActionDispatch

    var title: String {
        return localizationProvider.getLocalizedString(.onHoldMessage)
    }
    var subtitle: String?
    @Published var getActionButtonViewModel: PrimaryButtonViewModel?

    init(localizationProvider: LocalizationProviderProtocol,
         compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger,
         actionDispatch: @escaping ActionDispatch) {
        self.localizationProvider = localizationProvider
        self.compositeViewModelFactory = compositeViewModelFactory
        self.logger = logger
        self.actionDispatch = actionDispatch

        getActionButtonViewModel = compositeViewModelFactory.makePrimaryButtonViewModel(
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
        let action = CallingAction.ResumeRequested()
        actionDispatch(action)
    }

        func update(audioSessionState: AudioSessionState) {
            getActionButtonViewModel?.isDisabled = audioSessionState.status == .interrupted
        }
}
