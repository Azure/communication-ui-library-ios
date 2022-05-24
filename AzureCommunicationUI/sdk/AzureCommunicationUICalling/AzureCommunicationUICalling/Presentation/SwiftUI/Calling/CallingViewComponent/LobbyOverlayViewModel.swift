//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

protocol OverlayViewModelProtocol {
    var title: String { get }
    var subtitle: String? { get }
    var getActionButtonViewModel: PrimaryButtonViewModel? { get }
}

struct LobbyOverlayViewModel: OverlayViewModelProtocol {
    private let localizationProvider: LocalizationProviderProtocol

    init(localizationProvider: LocalizationProviderProtocol) {
        self.localizationProvider = localizationProvider
    }

    var title: String {
        return localizationProvider.getLocalizedString(.waitingForHost)
    }

    var subtitle: String? {
        return localizationProvider.getLocalizedString(.waitingDetails)
    }

    var getActionButtonViewModel: PrimaryButtonViewModel?
}

class OnHoldOverlayViewModel: OverlayViewModelProtocol, ObservableObject {
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactory
    private let logger: Logger

    private var actionButtonViewModel: PrimaryButtonViewModel?

//    var audioSessionState: AudioSessionState

    init(localizationProvider: LocalizationProviderProtocol,
         compositeViewModelFactory: CompositeViewModelFactory,
         logger: Logger) {
        self.localizationProvider = localizationProvider
        self.compositeViewModelFactory = compositeViewModelFactory
        self.logger = logger
    }

    var title: String {
        return localizationProvider.getLocalizedString(.onHoldMessage)
    }

    var subtitle: String?

    var getActionButtonViewModel: PrimaryButtonViewModel? {
        if actionButtonViewModel == nil {
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
        return actionButtonViewModel
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

//    •New added State:
//
//    •AudioSessionState:
//
//    •active
//
//    •interrupted
//
//    •New added Actions:
//
//    •LifecycleAction.AudioInterrupted
//
//    •LifecycleAction.AudioEngaged
//
//    •CallAction.ResumeRequested
//
//    •CallAction.HoldRequested
//
//    •AudioSessionManager:
//
//    •Send AudioInterrupted when interrupt began -> state: interrupted -> middleware: holdCall
//
//    Send AudioEngaged when timer detect audio session is not used by other apps
//
//    •Send AudioEngaged when interruption ended -> state: free -> middleware: resumeCall
//
//    •CallingViewModel:
//
//    •Show holding state layer when call is hold
//
//    •Enable resume button when audioSessionState is `active`
}
