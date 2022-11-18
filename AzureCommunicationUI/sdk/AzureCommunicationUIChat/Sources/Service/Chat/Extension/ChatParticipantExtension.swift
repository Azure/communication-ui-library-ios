//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore
import AzureCommunicationChat

extension ChatParticipant {
    func toParticipantInfoModel(_ localParticipantId: String = "") -> ParticipantInfoModel {
        return ParticipantInfoModel(
            identifier: self.id,
            displayName: self.displayName ?? "",
            isLocalParticipant: id.stringValue == localParticipantId,
            sharedHistoryTime: self.shareHistoryTime ?? Iso8601Date())
    }
}

extension SignalingChatParticipant {
    func toParticipantInfoModel(_ localParticipantId: String = "") -> ParticipantInfoModel {
        return ParticipantInfoModel(
            identifier: self.id!,
            displayName: self.displayName ?? "",
            isLocalParticipant: id?.stringValue == localParticipantId,
            sharedHistoryTime: self.shareHistoryTime ?? Iso8601Date())
    }
}
