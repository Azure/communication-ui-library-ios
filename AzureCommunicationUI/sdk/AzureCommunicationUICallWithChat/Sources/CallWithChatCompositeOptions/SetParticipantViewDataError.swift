//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationUICalling

/// An error that occurs during setting participants view data.
public enum SetParticipantViewDataError: String, Error {
    /// Error when the remote participant is not in the call.
    case participantNotInCall

    func getCallCompositeSetParticipantViewDataError() -> AzureCommunicationUICalling.SetParticipantViewDataError {
        switch self {
        case .participantNotInCall:
            return .participantNotInCall
        }
    }
}

extension AzureCommunicationUICalling.SetParticipantViewDataError {
    func getCallWithChatCompositeSetParticipantViewDataError()
            -> AzureCommunicationUICallWithChat.SetParticipantViewDataError {
        // fix the warning during error handling spike
        switch self {
        case .participantNotInCall:
            return .participantNotInCall
        }
    }
}
