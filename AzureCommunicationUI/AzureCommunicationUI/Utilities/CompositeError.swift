//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum CompositeError: String, LocalizedError, Equatable {

    case invalidSDKWrapper = "InvalidSDKWrapper"
    case invalidLocalVideoStream = "InvalidLocalVideoStream"
    case callCompositeNotLaunched = "CallCompositeNotLaunched"
    case remoteParticipantNotFound = "RemoteParticipantNotFound"
    case invalidRemoteParticipantAvatarImage = "InvalidRemoteParticipantAvatarImage"

    var localizedDescription: String { return NSLocalizedString(self.rawValue, comment: "") }
}
