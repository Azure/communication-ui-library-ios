//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class ParticipantGridCellViewModelMocking: ParticipantGridCellViewModel {
    private let updateParticipantModelCompletion: ((ParticipantInfoModel, LifeCycleState) -> Void)?

    init(participantModel: ParticipantInfoModel,
         updateParticipantModelCompletion: ((ParticipantInfoModel, LifeCycleState) -> Void)?) {
        self.updateParticipantModelCompletion = updateParticipantModelCompletion
        super.init(localizationProvider: LocalizationProviderMocking(),
                   accessibilityProvider: AccessibilityProviderMocking(),
                   participantModel: participantModel,
                   lifeCycleState: LifeCycleState(currentStatus: .foreground))
    }

    override func update(participantModel: ParticipantInfoModel, lifeCycleState: LifeCycleState) {
        updateParticipantModelCompletion?(participantModel, lifeCycleState)
    }
}
