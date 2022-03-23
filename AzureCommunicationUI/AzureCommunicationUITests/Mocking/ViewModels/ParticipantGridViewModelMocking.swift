//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class ParticipantGridViewModelMocking: ParticipantGridViewModel {
    private let updateState: ((CallingState, RemoteParticipantsState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactory,
         localizationProvider: LocalizationProvider,
         updateState: ((CallingState, RemoteParticipantsState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   localizationProvider: localizationProvider)
    }

    override func update(callingState: CallingState,
                         remoteParticipantsState: RemoteParticipantsState) {
        updateState?(callingState, remoteParticipantsState)
    }
}
