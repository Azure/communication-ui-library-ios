//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public enum ParticipantViewDataSetError: String, Error {
    /// Error when the remote participant is not found in the call.
    case remoteParticipantNotFound = "RemoteParticipantNotFound"
}
