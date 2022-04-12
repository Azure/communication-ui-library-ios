//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
@testable import AzureCommunicationUI

class AvatarManagerMocking: AvatarViewManager {
    func setLocalAvatar(_ image: UIImage) {
    }

    func getLocalAvatar() -> UIImage? {
        return nil
    }
}
