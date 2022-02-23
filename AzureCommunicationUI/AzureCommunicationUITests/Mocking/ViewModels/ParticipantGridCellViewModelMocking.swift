//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUI

class ParticipantGridCellViewModelMocking: ParticipantGridCellViewModel {
    private let updateParticipantModelCompletion: ((ParticipantInfoModel) -> Void)?

    init(compositeViewModelFactory: CompositeViewModelFactory,
         participantModel: ParticipantInfoModel,
         updateParticipantModelCompletion: ((ParticipantInfoModel) -> Void)?) {
        self.updateParticipantModelCompletion = updateParticipantModelCompletion
        super.init(compositeViewModelFactory: compositeViewModelFactory,
                   participantModel: participantModel)
    }

    override func update(participantModel: ParticipantInfoModel) {
        updateParticipantModelCompletion?(participantModel)
    }
}
