//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore
import AzureCommunicationCommon
import AzureCommunicationChat

extension ChatParticipant {
    func toParticipantInfoModel(_ localParticipantId: CommunicationIdentifier) -> ParticipantInfoModel {
        return ParticipantInfoModel(
            identifier: self.id,
            displayName: self.displayName ?? "",
            isLocalParticipant: id.stringValue == localParticipantId.stringValue,
            sharedHistoryTime: self.shareHistoryTime ?? Iso8601Date())
    }
}

extension SignalingChatParticipant {
    func toParticipantInfoModel(_ localParticipantId: CommunicationIdentifier) -> ParticipantInfoModel {
        return ParticipantInfoModel(
            identifier: self.id!,
            displayName: self.displayName ?? "",
            isLocalParticipant: id?.stringValue == localParticipantId.stringValue,
            sharedHistoryTime: self.shareHistoryTime ?? Iso8601Date())
    }
}
