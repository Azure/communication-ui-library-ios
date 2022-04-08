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
    let avatar: UIImage?
    let displayName: String?

    public init(_ avatar: UIImage?,
                displayName: String? = nil) {
        self.avatar = avatar
        self.displayName = displayName
    }
}
