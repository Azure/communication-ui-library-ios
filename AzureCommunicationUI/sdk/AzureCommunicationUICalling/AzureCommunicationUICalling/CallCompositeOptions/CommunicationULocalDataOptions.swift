//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

public struct CommunicationUILocalDataOptions {
    let participantViewData: ParticipantViewData

    public init(_ participantViewData: ParticipantViewData) {
        self.participantViewData = participantViewData
    }
}

public struct ParticipantViewData {
    let avatarImage: UIImage?
    let renderDisplayName: String?

    public init(avatar: UIImage?,
                renderDisplayName: String? = nil) {
        self.avatarImage = avatar
        self.renderDisplayName = renderDisplayName
    }
}
