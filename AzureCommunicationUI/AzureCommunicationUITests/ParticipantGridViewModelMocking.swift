//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class ParticipantGridViewModelMocking: ParticipantGridViewModel {
    private(set) var updateState: ((RemoteParticipantsState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactory,
         updateState: ((RemoteParticipantsState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory)
    }

    override func update(remoteParticipantsState: RemoteParticipantsState) {
        updateState?(remoteParticipantsState)
    }
}
