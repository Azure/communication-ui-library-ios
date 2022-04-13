//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

public struct CommunicationUILocalDataOptions {
    let localPersona: CommunicationUIPersonaData

    public init(_ localPersona: CommunicationUIPersonaData) {
        self.localPersona = localPersona
    }
}

public struct CommunicationUIPersonaData {
    let avatarImage: UIImage?
    let renderDisplayName: String?

    public init(_ avatar: UIImage?,
                displayName: String? = nil) {
        self.avatarImage = avatar
        self.renderDisplayName = displayName
    }
}
