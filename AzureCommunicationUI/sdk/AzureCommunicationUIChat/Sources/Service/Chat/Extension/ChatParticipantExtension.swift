//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore
import AzureCommunicationChat

extension ChatParticipant {
    func toParticipantInfoModel() -> ParticipantInfoModel {
        return ParticipantInfoModel(
            identifier: self.id,
            displayName: self.displayName ?? "",
            sharedHistoryTime: self.shareHistoryTime ?? Iso8601Date())
    }
}

extension SignalingChatParticipant {
    func toParticipantInfoModel() -> ParticipantInfoModel {
        return ParticipantInfoModel(
            identifier: self.id!,
            displayName: self.displayName ?? "",
            sharedHistoryTime: self.shareHistoryTime ?? Iso8601Date())
    }
}
