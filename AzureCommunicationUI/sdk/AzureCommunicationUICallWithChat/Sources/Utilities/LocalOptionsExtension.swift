//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationUICalling
import AzureCommunicationChat

extension LocalOptions {
    func getCallCompositeLocalOptions() -> AzureCommunicationUICalling.LocalOptions {
        let participantViewData = participantViewData.getCallCompositeParticipantViewData()
        return AzureCommunicationUICalling.LocalOptions(participantViewData: participantViewData)
    }
}
/// Object to represent participants data
extension ParticipantViewData {
    func getCallCompositeParticipantViewData() -> AzureCommunicationUICalling.ParticipantViewData {
        return AzureCommunicationUICalling.ParticipantViewData(avatar: avatarImage,
                                                               displayName: displayName)
    }
}
