//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class ParticipantGridViewModelMocking: ParticipantGridViewModel {
    private let updateState: ((CallingState, RemoteParticipantsState,
                               PictureInPictureState, LifeCycleState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         updateState: ((CallingState, RemoteParticipantsState,
                        PictureInPictureState, LifeCycleState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   localizationProvider: localizationProvider,
         		   accessibilityProvider: accessibilityProvider,
                   isIpadInterface: false)
    }

    override func update(callingState: CallingState,
                         remoteParticipantsState: RemoteParticipantsState,
                         pipState: PictureInPictureState,
                         lifeCycleState: LifeCycleState) {
        updateState?(callingState, remoteParticipantsState, pipState, lifeCycleState)
    }
}
