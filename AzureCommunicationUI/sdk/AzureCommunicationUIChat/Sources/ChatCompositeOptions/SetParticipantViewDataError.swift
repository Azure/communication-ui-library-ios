//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// An error that occurs during setting participants view data.
enum SetParticipantViewDataError: String, Error {
    /// Error when the remote participant is not in the chat.
    case participantNotInChat
}
