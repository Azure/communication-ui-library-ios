//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class OnHoldOverlayViewModel: OverlayViewModelProtocol, ObservableObject {
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactory
    private let logger: Logger

    var title: String {
        return localizationProvider.getLocalizedString(.onHoldMessage)
    }
    var subtitle: String?
    @Published var getActionButtonViewModel: PrimaryButtonViewModel?

    //    var audioSessionState: AudioSessionState

    init(localizationProvider: LocalizationProviderProtocol,
         compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger) {
        self.localizationProvider = localizationProvider
        self.compositeViewModelFactory = compositeViewModelFactory
        self.logger = logger

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
//        let action: Action = CallAction.ResumeRequested()
//        dispatch(action)
    }

//        func update(audioSessionState: AudioSessionState) {
//            self.audioSessionState = audioSessionState
//
//            // Disable/enable resume button
//            actionButtonViewModel?.isDisabled = false
//        }
}
