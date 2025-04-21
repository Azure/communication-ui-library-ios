//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class ParticipantGridViewModelMocking: ParticipantGridViewModel {
    private let updateState: ((CallingState, RemoteParticipantsState,
                               VisibilityState, LifeCycleState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         updateState: ((CallingState, RemoteParticipantsState,
                        VisibilityState, LifeCycleState) -> Void)? = nil,
         rendererViewManager: RendererViewManager) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   localizationProvider: localizationProvider,
         		   accessibilityProvider: accessibilityProvider,
                   isIpadInterface: false,
                   callType: .groupCall,
                   rendererViewManager: rendererViewManager)
    }

    override func update(callingState: CallingState,
                         captionsState: CaptionsState,
                         rttState: RttState,
                         remoteParticipantsState: RemoteParticipantsState,
                         visibilityState: VisibilityState,
                         lifeCycleState: LifeCycleState) {
        updateState?(callingState, remoteParticipantsState, visibilityState, lifeCycleState)
    }
}
