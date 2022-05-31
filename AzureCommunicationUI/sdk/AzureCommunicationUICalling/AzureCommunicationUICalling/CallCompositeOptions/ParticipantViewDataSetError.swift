//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public enum SetParticipantViewDataError: String, Error {
    /// Error when the remote participant is not in the call.
    case participantNotInCall
}
