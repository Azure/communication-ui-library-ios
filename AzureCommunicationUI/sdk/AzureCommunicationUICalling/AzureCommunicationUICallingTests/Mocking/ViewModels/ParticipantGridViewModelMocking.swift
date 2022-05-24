//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class ParticipantGridViewModelMocking: ParticipantGridViewModel {
    private let updateState: ((CallingState, RemoteParticipantsState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         updateState: ((CallingState, RemoteParticipantsState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   localizationProvider: localizationProvider,
         		   accessibilityProvider: accessibilityProvider,
                   isIPadInterface: false)
    }

    override func update(callingState: CallingState,
                         remoteParticipantsState: RemoteParticipantsState) {
        updateState?(callingState, remoteParticipantsState)
    }
}
