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
    let localizationProvider: LocalizationProviderProtocol

    var title: String {
        return localizationProvider.getLocalizedString(.waitingForHost)
    }

    var subtitle: String? {
        return localizationProvider.getLocalizedString(.waitingDetails)
    }

    var getActionButtonViewModel: PrimaryButtonViewModel?
}

struct OnHoldOverlayViewModel: OverlayViewModelProtocol {
    let localizationProvider: LocalizationProviderProtocol
    let compositeViewModelFactory: CompositeViewModelFactory
    let logger: Logger

//    var audioSessionState: AudioSessionState

    var title: String {
        return localizationProvider.getLocalizedString(.onHold)
    }

    var subtitle: String? {
        return localizationProvider.getLocalizedString(.onHoldMessage)
    }

    var getActionButtonViewModel: PrimaryButtonViewModel? {
        compositeViewModelFactory.makePrimaryButtonViewModel(
            buttonStyle: .primaryFilled,
            buttonLabel: localizationProvider.getLocalizedString(.resume),
            iconName: nil) {
                self.logger.debug("Resume from hold button tapped")
                self.resumeButtonTapped()
        }
    }

    func resumeButtonTapped() {
//        let action: Action = CallAction.ResumeRequested()
//        dispatch(action)
    }

        func update(audioSessionState: AudioSessionState) {
            self.audioSessionState = audioSessionState



        }

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
