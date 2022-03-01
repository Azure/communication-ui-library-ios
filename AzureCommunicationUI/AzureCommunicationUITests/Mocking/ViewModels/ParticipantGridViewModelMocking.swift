//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class ParticipantGridViewModelMocking: ParticipantGridViewModel {
    private let updateState: ((RemoteParticipantsState, LifeCycleState) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactory,
         updateState: ((RemoteParticipantsState) -> Void)? = nil) {
        self.updateState = updateState
        super.init(compositeViewModelFactory: compositeViewModelFactory)
    }

    override func update(remoteParticipantsState: RemoteParticipantsState, lifeCycleState: LifeCycleState) {
        updateState?(remoteParticipantsState, lifeCycleState)
    }
}
