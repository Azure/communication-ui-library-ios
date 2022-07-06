//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
@testable import AzureCommunicationUICalling

class ParticipantGridCellViewModelMocking: ParticipantGridCellViewModel {
    private let updateParticipantModelCompletion: ((ParticipantInfoModel) -> Void)?

    init(participantModel: ParticipantInfoModel,
         updateParticipantModelCompletion: ((ParticipantInfoModel) -> Void)?) {
        self.updateParticipantModelCompletion = updateParticipantModelCompletion
        super.init(localizationProvider: LocalizationProviderMocking(),
                   accessibilityProvider: AccessibilityProviderMocking(),
                   participantModel: participantModel)
    }

    override func update(participantModel: ParticipantInfoModel) {
        updateParticipantModelCompletion?(participantModel)
    }
}
