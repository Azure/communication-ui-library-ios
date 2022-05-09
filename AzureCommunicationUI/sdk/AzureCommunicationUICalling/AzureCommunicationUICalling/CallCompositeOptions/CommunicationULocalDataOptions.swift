//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

public struct CommunicationUILocalDataOptions {
    let localPersona: PersonaData

    public init(_ localPersona: PersonaData) {
        self.localPersona = localPersona
    }
}

public struct PersonaData {
    let avatarImage: UIImage?
    let renderDisplayName: String?

    public init(avatar: UIImage?,
                renderDisplayName: String? = nil) {
        self.avatarImage = avatar
        self.renderDisplayName = renderDisplayName
    }
}
